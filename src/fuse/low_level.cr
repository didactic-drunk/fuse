require "./lib"
require "./base"

module Fuse
  abstract class LowLevel < Base
  end
end

require "./low_level/*"

module Fuse
  # :nodoc:
  FUSE_CAP_BIG_WRITES = (1 << 5)
  FUSE_CAP_ATOMIC_O_TRUNC = (1 << 3)

  # Base class for user-defined file systems.  Sub-class it and build your own!
  # Use `#run!` to start it.
  #
  # There are many methods in this class, but you'll probably only need a
  # couple.  Most expect a return type of *something* (Which is the result and
  # is treated as success), `Int32` (Treated as errno code) or `nil` which will
  # return a **ENOSYS** (*Function not implemented*).
  #
  # Standard arguments are:
  #  * **fci** `Lib::FuseConnInfo`, init connection info
  #  *
  #  * **ino** `UInt64`, inode number
  #  * **path** `String`, the path of the file or directory
  #  * **handle** `UInt64`, a numeric file handle
  #  * **fi** `Lib::FileInfo`, handle information passed from FUSE
  #  *
  #  * **buffer** `Bytes`, a input or output buffer
  #  * **size** `LibC::SizeT`, buffer size (typically)
  #  * **offset** `LibC::OffT`, an offset in a file or directory listing
  #
  # These arguments may not have explicit data types for readability purposes.
  #
  # Exceptions are noted in each methods documentation.
  abstract class LowLevel < Base
    Log = ::Log.for self

    @session_ops = Lib::SessionOps.new
    @operations = Lib::FuseLowlevelOps.new

    def initialize
      super

      spawn_workers
    end

    ## FUSE functions.  Override these as you need them.

    def init(fcip) : Nil
# macfuse reports 0 for capable
# max_background is 0?

#  define FUSE_ENABLE_SETVOLNAME(i)       (i)->want |= FUSE_CAP_VOL_RENAME
#  define FUSE_ENABLE_XTIMES(i)           (i)->want |= FUSE_CAP_XTIMES
#  define FUSE_ENABLE_CASE_INSENSITIVE(i) (i)->want |= FUSE_CAP_CASE_INSENSITIVE

# probably provide
# * FUSE_CAP_ASYNC_READ: filesystem supports asynchronous read requests - ?
# * FUSE_CAP_POSIX_LOCKS: filesystem supports "remote" locking - ?
# * FUSE_CAP_ATOMIC_O_TRUNC: filesystem handles the O_TRUNC open flag - probably - test differences
# * FUSE_CAP_EXPORT_SUPPORT: filesystem handles lookups of "." and ".." - why?  impact?
# * FUSE_CAP_BIG_WRITES: filesystem can handle write size larger than 4kB - benchmark
      want = fcip.value.want
      want |= FUSE_CAP_ATOMIC_O_TRUNC | FUSE_CAP_BIG_WRITES
      fcip.value.want = want

      Log.info &.emit(fcip.value.inspect)
    end

    # Runs the file system.  This will block until the file-system has been
    # unmounted.
    def run!(args = ARGV)
      fuse_args = fuse_arguments args

      session(fuse_args)
    end

    private def session(fuse_args)
Log.debug { "parse_cmdline" }
      r = Lib.parse_cmdline pointerof(fuse_args), out mnt, out multithread, out foreground
      raise "parse_cmdline" unless r == 0

#p multithread, foreground

Log.debug &.emit("mount", path: String.new(mnt))
      chan = Lib.mount mnt, pointerof(fuse_args)
      raise "fuse_mount" unless chan

Log.debug { "lowlevel_new" }
      data_ptr = self.as(Void*)
      se = Lib.lowlevel_new pointerof(fuse_args), pointerof(@operations), sizeof(Lib::FuseLowlevelOps), data_ptr
      raise "lowlevel_new" unless se

      set_signal_handlers se do
        add_chan se, chan do
          rch = Channel(Exception?).new

          spawn do
            Log.debug { "session_loop mt?" }
            r = Lib.session_loop se
#           r = Lib.session_loop_mt se
            raise "session_loop" unless r == 0
          rescue ex
            Log.warn { ex.inspect }
            rch.send ex
          else
            rch.send nil
          end

          if ex = rch.receive
            raise ex
          end
        end
      end
    end

    private def set_signal_handlers(session)
      r = Lib.set_signal_handlers session
      raise "set_signal_handlers" unless r == 0

      begin
        yield
      ensure
# BUG: unset
#        Lib.set_signal_handlers session
      end
    end

    private def add_chan(session, chan)
      Lib.session_add_chan session, chan
      yield
    ensure
      Lib.session_remove_chan chan
    end

    protected def set_up_operations
      Log.debug { "set_up_operations" }

      @operations.init = ->(user_data: Void*, fcip : Lib::FuseConnInfo*) do
        low_level = user_data.as(LowLevel*).value
        low_level.init fcip
      end
    end

    OPERATION_CALLBACKS_AVAILABLE = [] of Symbol
    OPERATION_CALLBACKS_REGISTERED = [] of Symbol
    OPERATION_CALLBACKS_REGISTERED_ASYNC = [] of Symbol

    macro op_callback(*args, async = false)
      {% for arg in args %}
        {% arg_sym = ":#{arg.id}".id %}
        {% raise "unknown callback #{arg} available: #{OPERATION_CALLBACKS_AVAILABLE}" unless OPERATION_CALLBACKS_AVAILABLE.includes?(arg_sym) %}

        {% OPERATION_CALLBACKS_REGISTERED << arg_sym %}
        {% OPERATION_CALLBACKS_REGISTERED_ASYNC << arg_sym %}
      {% end %}
    end

    annotation OperationTransform
    end

    macro define_op(name, args, return_args = nil, &block)
      {% OPERATION_CALLBACKS_AVAILABLE << ":#{name.id}".id %}

      # [ino, ..., fi*]
      {% args_vars = args.map(&.var) %}
      # [UInt64, ..., Pointer(Lib::FuseFileInfo)]
      {% args_types = args.map(&.type) %}
      # [ino : UInt64, ..., fi : Lib::FuseFileInfo]
      # Same format as `args`.
      {% transform_return = return_args || args %}
      # [ino, ..., fi]
      # Same format as `args_vars`
      {% transform_return_vars = transform_return.map(&.var) %}
      # [UInt64, ..., Lib::FuseFileInfo]
      # Same format as `args_types`
      {% transform_return_types = transform_return.map(&.type) %}

      @[OperationTransform(name: {{ name }}, args: {{ args }}, args_vars: {{ args_vars }}, transform_return: {{ transform_return }}, transform_return_vars: {{ transform_return_vars }}, transform_return_types: {{ transform_return_types }})]
      {% if block %}
        def {{ name }}_transform({{ *args }}) : {{ transform_return_types }}
            {{yield}}
        end
      {% else %} # Returns same values/types.  NOOP, but annotation used to construct channel and receive loop.
        def {{ name }}_transform({{ *args }}) : {{ transform_return_types }}
           {{ args_vars }}
        end
      {% end %}
    end


    define_op lookup, {parent_ino : UInt64, name : LibC::Char*}, {parent_ino : UInt64, name : String} do
      {parent_ino, String.new(name)}
    end
    define_op access, {ino : UInt64, mask : LibC::Int}

    {% for func in %w(getattr) %}
      # fi always NULL.  When not NULL same args as open.
      define_op {{func.id}}, {ino : UInt64, fi : Lib::FuseFileInfo*}, {ino : UInt64, fi : Nil} do
        {ino, nil}
      end
    {% end %}

    {% for func in %w(open flush release opendir releasedir) %}
      define_op {{func.id}}, {ino : UInt64, fi : Lib::FuseFileInfo*}, {ino : UInt64, fi : Lib::FuseFileInfo} do
        {ino, fi.value}
      end
    {% end %}

    {% for func in %w(read readdir) %}
      define_op {{func.id}}, {ino : UInt64, size : LibC::SizeT, offset : LibC::OffT, fi : Lib::FuseFileInfo*}, {ino : UInt64, size : LibC::SizeT, offset : LibC::OffT, fi : Lib::FuseFileInfo} do
        {ino, size, offset, fi.value}
      end
    {% end %}

    define_op setattr, {ino : UInt64, stat : LibC::Stat*, to_set : LibC::Int, fi : Lib::FuseFileInfo*}, {ino : UInt64, stat : LibC::Stat, to_set : LibC::Int, fi : Lib::FuseFileInfo } do
      {ino, stat.value, to_set, fi.value}
    end

    define_op write, {ino : UInt64, buf : LibC::Char*, size : LibC::SizeT, offset : LibC::OffT, fi : Lib::FuseFileInfo*}, {ino : UInt64, buf : Bytes, offset : LibC::OffT, fi : Lib::FuseFileInfo } do
      {ino, Slice.new(buf, size), offset, fi.value}
    end

    define_op mkdir, {parent_ino : UInt64, name : LibC::Char*, mode : Lib::ModeT}, {parent_ino : UInt64, name : String, mode : Lib::ModeT} do
      {parent_ino, String.new(name), mode}
    end
    define_op rmdir, {parent_ino : UInt64, name : LibC::Char*}, {parent_ino : UInt64, name : String} do
      {parent_ino, String.new(name)}
    end

    define_op create, {parent_ino : UInt64, name : LibC::Char*, mode : Lib::ModeT, fi : Lib::FuseFileInfo*}, {parent_ino : UInt64, name : String, mode : Lib::ModeT, fi : Lib::FuseFileInfo} do
      {parent_ino, String.new(name), mode, fi.value}
    end
    define_op rename, {src_parent_ino : UInt64, src_name : LibC::Char*, dst_parent_ino : UInt64, dst_name : LibC::Char*}, {src_parent_ino : UInt64, src_name : String, dst_parent_ino : UInt64, dst_name : String} do
      {src_parent_ino, String.new(src_name), dst_parent_ino, String.new(dst_name)}
    end
    define_op link, {ino : UInt64, dst_parent_ino : UInt64, dst_name : LibC::Char*}, {ino : UInt64, dst_parent_ino : UInt64, dst_name : String} do
      {ino, dst_parent_ino, String.new(dst_name)}
    end

#  * If the file's inode's lookup count is non-zero, the file
#  * system is expected to postpone any removal of the inode
#  * until the lookup count reaches zero (see description of the
#  * forget function).
    define_op unlink, {parent_ino : UInt64, name : LibC::Char*}, {parent_ino : UInt64, name : String} do
      {parent_ino, String.new(name)}
    end

    define_op forget, {ino : UInt64, nlookup : UInt64}

#    define_op , {}, {} do
 #     {}
  #  end


    macro finished
      {% transform_methods = @type.methods.select(&.annotation(OperationTransform)) %}
      {% transform_annotations = transform_methods.map(&.annotation(OperationTransform)) %}

      # Conditional(opt in) `abstract def` callback methods and callback registration
      {% for anno in transform_annotations %}
        {% name = anno[:name] %}
        {% args = anno[:args] %}
        {% args_vars = anno[:args_vars] %}
        {% transform_return = anno[:transform_return] %}
        {% transform_return_vars = anno[:transform_return_vars] %}

        {% if OPERATION_CALLBACKS_REGISTERED.includes?(":#{name.id}".id) %}
          abstract def {{name}}(req : Request, {{ transform_return.splat }}) : Nil

          def set_up_operations
Log.info &.emit("operation {{name}}")
#            if OPERATION_CALLBACKS_REGISTERED_ASYNC.includes?(:{{ name.id }}) # Send msg to @callback_chan.
#if false
if true
              @operations.{{ name }} = ->(reqp : Lib::FuseReqT, {{ *args }}) do
                req = Request.new reqp
                low_level = req.low_level

                dtup = low_level.{{ name }}_transform {{ args_vars.join(", ").id }}
Log.info &.emit("operation {{name}} async #{typeof(dtup)} #{dtup}")
                tup = { :{{ name }}, req, dtup }
Log.info &.emit("operation {{name}} async #{typeof(tup)} #{tup}")

                req.low_level.callback_chan.send tup
              end
            else # Directly call method.
              @operations.{{ name }} = ->(reqp : Lib::FuseReqT, {{ *args }}) do
Log.info &.emit("operation {{name}} sync")
                req = Request.new reqp
                low_level = req.low_level

                dtup = low_level.{{ name }}_transform {{ args_vars.join(", ").id }}

                {% mvars = [] of String %}
                {% for argname, i in transform_return_vars %}
                  {% mvars << "#{argname}: dtup[#{i}]".id %}
                {% end %}

                low_level.{{ name }}(req, {{ mvars.splat }})
              end
            end

            previous_def
          end
        {% end %}
      {% end %}


      # For switch statement (avoiding casting bug) and channel type consolidation.
      # {} of transform_return_value_type => [method_name, ...]
      {% msg_types = {} of Nil => Nil %}
      {% for method in transform_methods %}
        {% anno = method.annotation(OperationTransform) %}
        {% return_type = anno[:transform_return_types] %}
        {% return_type2 = method.return_type %}
        {% if methods = msg_types[return_type] %}
           {% methods << method %}
        {% else %}
           {% methods = msg_types[return_type] = [] of String %}
           {% methods << method %}
        {% end %}
      {% end %}

      {% channel_msg_types = msg_types.map { |r, _| "{Symbol, Request, #{r}}".id } %}
      {% channel_msg_types = [Nil] if channel_msg_types.empty? %}

# BUG: configurable @callback_chan buf size
      # :nodoc:
      getter callback_chan : Channel({{ channel_msg_types.join(" | ").id}}) = Channel({{ channel_msg_types.join(" | ").id}}).new 8

@logged = false

      def callback_receive_loop
unless @logged
Log.notice { "handles {{channel_msg_types}}" }
        {% for msg_type, methods in msg_types %}
Log.notice { "handles {{msg_type}} {{methods}}" }
        {% end %}
end
          @logged = true

        while msg = @callback_chan.receive?
Log.error { "received msg #{msg[0]} req: #{msg[1].inspect} data: #{msg[2].inspect}" }
          name = msg[0]
          req = msg[1]
          mdata = msg[2]

Log.error { "handles ch #{typeof(@callback_chan)}" }
Log.error { "handles {{msg_types}}" }
          {% for msg_type, methods in msg_types %}
Log.error { "handles {{msg_type}} {{msg_type.id}}" }
          {% end %}

          case mdata
          {% for msg_type, methods in msg_types %}
            when {{ msg_type.id }}
              case name
              {% for method in methods %}
                {% anno = method.annotation(OperationTransform) %}
                {% name = anno[:name] %}

                when :{{ name.id }} # Symbol with name of func
                  {{ name.id }}_data = mdata.as({{ msg_type.id }})

Log.error { "received msg #{name} req: #{req.inspect} data: #{mdata.inspect} #{typeof(mdata)}" }
                  {% if OPERATION_CALLBACKS_REGISTERED.includes?(":#{name.id}".id) %}
                    {% mvars = [] of String %}
                    {% for argname, i in anno[:transform_return_vars] %}
                      {% mvars << "#{argname}: #{name}_data[#{i}]".id %}
                    {% end %}
Log.notice { "run {{name}}  {{mvars}}" }
                    {{ name.id }}(req, {{ mvars.splat }})
req.unsupported
                  {% end %}
              {% end %}
              else
                raise "unhandled cb #{name}"
            end
          {% end %}
#when ::Tuple(UInt64, Int32)
#                raise "unhandled msg2 type #{name} #{typeof(mdata)} #{mdata}"
#when {UInt64, Int32}
#                raise "unhandled msg2 type #{name} #{typeof(mdata)} #{mdata}"
            else
                raise "unhandled msg type #{name} #{typeof(mdata)} #{mdata}"
          end
        end
      end
    end

    private def spawn_workers
# BUG: configurable workers
      1.times do
        spawn do
          callback_receive_loop
# BUG: handle errors
        rescue ex
#        ensure
          abort "shouldn't exit spawn #{ex.inspect}"
        end
      end
    end


    private macro invoke(method, req2, ino, *arguments)
#    private macro invoke(method, req2, *arguments)
      %req3 = Request.new({{req2}})
Log.warn { "invoke {{method}} #{%req3} #{ {{ino}} } {{arguments}}" }
      %req3.low_level.{{ method }}(%req3, {{ino}}, {{ arguments.splat }})
    end

    private macro invoke_file(method, req, path, fi)
Log.warn { "invoke {{method}} {{path}} {{fi}}" }
      invoke({{ method }}, {{ req }}, String.new({{ path }}), {{ fi }}.value.fh, {{ fi }})
    end

    private macro invoke_file(method, path, fi, *arguments)
Log.warn { "invoke {{method}} {{path}} {{fi}} {{arguments}}" }
      invoke({{ method }}, String.new({{ path }}), {{ fi }}.value.fh, {{ arguments.splat }}, {{ fi }})
    end
  end
end

# readlink symlink

# flush fsync
# fsyncdir

# statfs

# listxattr getxattr setxattr removexattr

# statfs
# getlk setlk flock
# ioctl poll
# fallocate - NO?

# write_buf (0 copy)

# ? retrieve_reply
# forget_multi

#   void (*readlink) (fuse_req_t req, fuse_ino_t ino);
# *   fuse_reply_readlink


## Entry responses
#void (*mknod) (fuse_req_t req, fuse_ino_t parent, const char *name,
#          mode_t mode, dev_t rdev);
#  * Create a regular file, character device, block device, fifo or
#  * socket node.
# parent inode number of the parent directory

#void (*symlink) (fuse_req_t req, const char *link, fuse_ino_t parent,
#      const char *name);
