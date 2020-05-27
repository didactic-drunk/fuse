require "./low_level"

class Fuse::MidLevel
	Log = ::Log.for self

#	class Fs(FileT, DirT)
	class Fs
#		@file_handles = {} of UInt64 => File|Dir

		getter! root : Inode::Dir { @backend.root }

		def initialize(@backend : Backend)
		end

		def post_init
#			@root = Inode::Dir.new self
#			inode_add root
		end


		def inodes
			@backend.inodes
		end

		# yield `Inode` or reply ENOENT
		def with_inode(req, ino) : Nil
			if inode = inodes[ino]?
				yield inode
			else
# Not sure what to return.  ENOENT is indistinguisable in lookup for ino(notexist) vs ino(exists)/name(notexist)
#				req.reply_err Errno::ENOENT
				req.reply_err Errno::ENETDOWN
			end
		end

		# yield `File` or reply E?
		def with_file_inode(req, ino : UInt64, & : Inode::File -> _) : Nil
			with_inode req, ino do |inode|
				with_file_inode req, inode do |finode|
					yield finode
				end
			end
		end

		# yield `File` or reply E?
		def with_file_inode(req, inode : Inode, & : Inode::File -> _) : Nil
			case inode.st_ftype
			when LibC::S_IFREG
				file = inode.as(Inode::File)
				yield file
			else
				Log.notice &.emit("file_inode E? #{typeof(inode)} #{inode.st_ftype}", ino: inode.ino.to_i)
				req.reply_err Errno::ENOTDIR
			end
		end

		# yield `Dir` or reply ENOTDIR
		def with_dir_inode(req, ino : UInt64, & : Inode::Dir -> _) : Nil
			with_inode req, ino do |inode|
				with_dir_inode req, inode do |dir|
					yield dir
				end
			end
		end

		# yield `Dir` or reply ENOTDIR
		def with_dir_inode(req, inode : Inode, & : Inode::Dir -> _) : Nil
			case inode.st_ftype
			when LibC::S_IFDIR
				dir = inode.as(Inode::Dir)
				yield dir
			else
				Log.notice &.emit("dir_inode ENOTDIR #{typeof(inode)} #{inode.st_ftype}", ino: inode.ino.to_i)
				req.reply_err Errno::ENOTDIR
			end
		end

#		def with_open_handle(req, ino)
#		end

		# yield `Open::File` or reply EBADF
		def with_open_file_handle(req, ino, fh : UInt64) : Nil
p @backend.open_file_handles.keys
			if fhandle = @backend.open_file_handles[fh]?
				yield fhandle
			else
				Log.info &.emit("with_open_file_handle EBADF", ino: ino.to_s, fh: fh.to_s)
				req.reply_err Errno::EBADF
			end
		end

		# yield `Open::Dir` or reply EBADF
		def with_open_dir_handle(req, ino, fh : UInt64) : Nil
			if dhandle = @backend.open_dir_handles[fh]?
				yield dhandle
			else
				req.reply_err Errno::EBADF
			end
		end

		delegate inum_new, to: backend
	end

	module Open
		abstract class File
			delegate backend, to: @inode

			def initialize(@inode : Inode::File)
			end

			abstract def read(size, offset) : Bytes
			abstract def write(buf : Bytes, offset) : Int32
			abstract def release : Nil
		end

		abstract class Dir
			getter inode : Inode::Dir

			delegate backend, to: @inode

			def initialize(@inode : Inode::Dir)
			end

			abstract def releasedir : Nil
		end
	end

	abstract class Inode
		UID = `id -u`.to_i
		GID = `id -g`.to_i

		abstract class File < Inode
			def st_ftype
				LibC::S_IFREG
			end

			abstract def open(fi) : UInt64
		end

		abstract class Dir < Inode
			def each_child2
				@children.each do |name, ino|
# BUG: get inode
					yield name, ino
				end
			end

			def st_ftype
				LibC::S_IFDIR
			end

			def st_perm
				0o755
			end

			abstract def opendir(fi) : UInt64
			abstract def children
		end

#		class Root < Dir
#		end

		getter backend : Backend
		getter ino : UInt64

#		def initialize(@fs : Fs(Inode::File, Inode::Dir))
#		def initialize(@fs : Fs)
		def initialize(@backend : Backend, @ino : UInt64)
		end

		def stat
# dev, times
			stat = LibC::Stat.new
			stat.st_ino = @ino
			stat.st_mode = st_mode
			stat.st_nlink = st_nlink
			stat.st_size = st_size
			stat.st_uid = st_uid
			stat.st_gid = st_gid
			stat
		end
#puts "getattr #{path} returning #{stat}"

# TODO: nlink
		def st_nlink
			1
		end

# TODO: dir size
		def st_size
			0
		end

		def st_mode
			st_ftype | st_perm
		end

		def st_perm
			0o644
		end

		def st_uid
			UID
		end

		def st_gid
			GID
		end
	end

	module Backend
# BUG: handle st_gen
# BUG: handle consistent inode numbers between mounts.  must pass more info or must provide stub that lock { checks inodes[] } for this to work.
		# Return a unique inode number.
		abstract def inum_new : UInt64

		# Root directory.
		abstract def root : Inode::Dir

		# Provide Hash like key access to inodes
		abstract def inodes
	end


	class Handler < Fuse::LowLevel
		Log = MidLevel::Log
# temp
		@ch = Channel({Request, LibC::Stat}).new 5

		def initialize(@fs : Fs)
puts "initializing"
			super()
#puts "initializing #{self.inspect}"

			spawn_loop
		end

#		async_handler :lookup
		op_callback :lookup, :access, async: true
		op_callback :getattr, :setattr
		op_callback :open, :flush, :release, :opendir, :releasedir
		op_callback :read, :readdir
		op_callback :write
#		op_callback :mkdir

#		def lookup(req : Request, parent_ino : UInt64, name : String) : Nil
		def lookup(req : Request, parent_ino : UInt64, name) : Nil
Log.info &.emit("lookup2 #{typeof(req)} #{typeof(parent_ino)} #{typeof(name)}")
#Log.info &.emit("lookup", parent_ino: parent_ino.to_i, name: name)
			@fs.with_dir_inode req, parent_ino do |parent_inode|
				if ino = parent_inode.children[name]?
					@fs.with_inode req, ino do |inode|
						req.reply_entry inode
					end
				else
					req.reply_err Errno::ENOENT
				end
			end
		end

		def access(req, ino, mask)
# BUG: query inode
			req.reply_err Errno.new(0)
		end

		def getattr(req, ino, fi) : Nil
Log.warn {  @fs.inodes.keys.inspect }
			if inode = @fs.inodes[ino]?
				req.reply_attr inode.stat
			else
				req.reply_err Errno::ENOENT
			end

#Log.warn { "ch send #{@ch.@queue.try &.@size} #{ino} #{fi}" }
#			msg = { req, stat }
#			@ch.send msg
#			req.reply_attr stat
	
#			return LibC::ENOENT
		end

		def setattr(req, ino, stat : LibC::Stat, to_set, fi) : Nil
Log.warn &.emit("setattr", ino: ino.to_i, stat: stat.inspect, to_set: to_set.to_i, fi: fi.inspect)
			if inode = @fs.inodes[ino]?
# BUG: can reference fh.  should use open file when does.  does it always?
# check what happens with chmod
# BUG: finish checking to_set and setting attributes
#				req.reply_attr inode.stat

				setattr_to_set req, inode, pointerof(stat), to_set, fi

#				stat = statp.value
#p stat
Log.warn { ::Time.new(stat.st_mtimespec, ::Time::Location::UTC).inspect } 
stat.st_mtimespec = to_timespec(::Time.utc)
#				stat.st_mtime = Time.local
				req.reply_attr stat
			else
				req.reply_err Errno::ENOENT
			end
		end

		def setattr_to_set(req, inode, statp, to_set, fi) : Nil
			31.times do |i|
				next if (to_set & 1<<i) == 0

Log.info &.emit("setattr_to_set", i: i)

				case i
#				when 3
# size
				when 28
				else
					Log.error &.emit("setattr_to_set unhandled bit", i: i)
				end
			end
		end


 private def to_timeval(time : ::Time)
    t = uninitialized LibC::Timeval
    t.tv_sec = typeof(t.tv_sec).new(time.to_unix)
    t.tv_usec = typeof(t.tv_usec).new(time.nanosecond // ::Time::NANOSECONDS_PER_MICROSECOND)
    t
  end
 private def to_timespec(time : ::Time)
    t = uninitialized LibC::Timespec
    t.tv_sec = typeof(t.tv_sec).new(time.to_unix)
    t.tv_nsec = typeof(t.tv_nsec).new(time.nanosecond)
    t
  end

		def open(req, ino, fi : Lib::FuseFileInfo) : Nil
Log.warn &.emit("open", fi: fi.inspect)
			@fs.with_inode req, ino do |inode|
				open_inode req, ino, inode, fi
			end
		end

	# common between open() and create()
	def open_inode(req, ino, inode, fi : Lib::FuseFileInfo) : Nil
			case inode.st_ftype
			when LibC::S_IFREG
				@fs.with_file_inode req, ino do |finode|
#					fi = fip.value

					begin
						fh = finode.open fi
					rescue ex
# what error?
						Log.error(exception: ex) { "finode.open" }
						req.reply_err Errno::EBADF
						raise ex
					else
						fi.fh = fh
#						fi.fh_old = fh
#fi.nonseekable = 1
#fi.keep_cache = 1
#fi.direct_io = 1
				Log.info &.emit("open", ino: ino.to_s, fh: fh.to_s, fi: fi.inspect)
#fip.value = fi
#fip.value.fh = fh
#req.reply_open fip

#						req.reply_open pointerof(fi)
#						req.reply_open fip
						req.reply_open pointerof(fi).as(Pointer(Void)).as(Pointer(Lib::FuseFileInfo))
#						req.unsupported
					end

				end
			when LibC::S_IFDIR
				req.reply_err Errno::EISDIR
# BUG: symlink/fifo maybe
			else
				req.unsupported
			end
	end

	# Fuse handles O_EXCL on it's own by using lookup() first.  Won't receive create call if info returned by lookup().
	# Still need to handle EXCL here because of race conditions with network backends.
	def create(req, parent_ino, name, mode, fi : Lib::FuseFileInfo) : Nil
		@fs.with_dir_inode req, parent_ino do |parent_inode|
Log.warn &.emit("create", name: name, mode: mode.to_i, fi: fiinspect)
			creat = mode & LibC::O_CREAT
			excl = false
# BUG: EXCL not available in crystal
#			excl = mode & LibC::O_EXCL

			unless creat
				Log.warn &.emit("create without creat flag", mode: mode.to_i)
# BUG: which error?
				req.unsupported
				return
			end


			if ino = parent_inode.children[name]?
				if excl
					Log.error &.emit("create file exists", mode: mode.to_i)
					req.reply_err Errno::EEXIST
					return
				end

# BUG: open should check mode
				open req, ino, fi
			else
# BUG: create inode
#				open req, ino, fip
				fhandle = parent_inode.create_file name, mode, fi
#				req.unsupported
			end
		end

		req.unsupported
	end

	def flush(req, ino, fi)
		req.reply_err Errno.new(0)
	end

	# Called once per open
	def release(req, ino, fi)
		@fs.with_open_file_handle req, ino, fi.fh do |fhandle|
			begin
				fhandle.release
			rescue ex
# what error?
				Log.error(exception: ex) { "fhandle.close" }
				req.reply_err Errno::EBADF
				raise ex
			else
				req.reply_err Errno.new(0)
			end
		end
	end

	def read(req, ino, size, offset, fi : Lib::FuseFileInfo)
#		fi = fip.value
Log.info &.emit("read", ino: ino.to_s, size: size.to_i, offset: offset.to_i, fi: fi.inspect)
		@fs.with_open_file_handle req, ino, fi.fh do |fhandle|
			slice = fhandle.read size, offset
			req.reply_buf slice
		end
	end

	def write(req, ino, buf, offset, fi) : Nil
#		fi = fip.value
		@fs.with_open_file_handle req, ino, fi.fh do |fhandle|
Log.info &.emit("write", ino: ino.to_s, size: buf.bytesize, fi: fi.inspect)
			begin
				wrote = fhandle.write buf, offset
			rescue ex
				Log.error(exception: ex) { "write" }
# BUG: what error?
				req.reply_err Errno::ECONNRESET
			else
				req.reply_write wrote
			end
		end
	end
# flush - does more than flush
# fsync


	def opendir(req : Request, ino, fi)
		@fs.with_dir_inode req, ino do |dinode|
#			fi = fip.value

			dh = dinode.opendir fi
			fi.fh = dh
#			fi.old_fh = dh
#			fi.writepage = dh
#			fi.direct_io = dh
# this contains keep_cache as generated from libgen
#			fi.keep_cache = dh
#			fi.padding = dh
#			fi.padding = dh
#			fi.purge_attr = dh
#			fi.purge_ubc = dh
#			fi.lock_owner = dh


			req.reply_open pointerof(fi)
#			req.reply_open pointerof(fi).as(Pointer(Void)).as(Pointer(Lib::FuseFileInfo))
		end
	end

	def releasedir(req : Request, ino : UInt64, fi) : Nil
#		fi = fip.value
		@fs.with_open_dir_handle req, ino, fi.fh do |dhandle|
			dhandle.releasedir

			req.reply_err Errno.new(0)
		end
	end

	def readdir(req, ino, size, offset, fi : Lib::FuseFileInfo)
#		fi = fip.value
		Log.warn &.emit("readdir", ino: ino.to_i, size: size.to_i, offset: offset.to_i, fi: fi.inspect)

# BUG: need dir inode lookup func
		@fs.with_open_dir_handle req, ino, fi.fh do |dhandle|
			if offset == 0
				dinode = dhandle.inode

				dirb = DirBuf.new req, size

				dirb.add ".", dinode.ino, dinode.st_mode
# BUG: fix ino num and parent
				dirb.add "..", 999, dinode.st_mode
# BUG: all kinds of wrong.  not keeping pos, not checking end of buf, not using file handle
				dinode.children.each do |name, cino|
# BUG: can error
# BUG: shouldn't do direct inode lookup.  use api
					cinode = @fs.inodes[cino]
					dirb.add name, cino, cinode.st_mode
				end

				req.reply_buf dirb.to_slice
			else
# BUG: SEEKING BROKEN.  long file list broken
				req.reply_buf Bytes.empty
			end

#			req.reply_err Errno::ENOTDIR
		end
	rescue ex
		Log.error(exception: ex) { "readdir" }
#		req.reply_err Errno::EBADF
# what error?
		req.reply_err Errno::EPROTONOSUPPORT
	end

	def spawn_loop
		spawn do
			loop do
				req, stat = @ch.receive
				Log.warn { "ch recv" }
sleep 0.1
				req.reply_attr stat
			end
		ensure
			Log.error { "spawn exit" }
		end
	end

	end
end

#testfs = TestFs.new
#testfs = Fuse::LowLevel.new
#testfs.run!
