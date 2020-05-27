require "./lib"

module Fuse
  abstract class Base
    Log = ::Log.for self

    def initialize
      set_up_operations
    end

    # Runs the file system.  This will block until the file-system has been
    # unmounted.
    def run!(argv = ARGV)
      fuse_args = fuse_arguments argv

      session(fuse_args)
    end

    private def fuse_arguments(argv) : Lib::FuseArgs
      arguments = argv.dup
      arguments.unshift PROGRAM_NAME
      arguments = arguments.map(&.to_unsafe).to_a

      fuse_args = Lib::FuseArgs.new
      fuse_args.argv = arguments
      fuse_args.argc = arguments.size
      fuse_args
    end
  end
end
