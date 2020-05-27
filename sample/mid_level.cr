require "../src/fuse/mid_level"

require "log"
require "option_parser"
require "colorize"

struct Log::StaticFormatter
  def timestamp
    ""
  end
end

class MyBackend
  include Fuse::MidLevel::Backend

# getter inodes : Hash(UInt64, Inode::File|Inode::Dir) = Hash(UInt64, Inode::File|Inode::Dir).new
  getter inodes : Hash(UInt64, MyFile | MyDir) = Hash(UInt64, MyFile | MyDir).new

  class MyOpenFile < Fuse::MidLevel::Open::File
    property data : Bytes = Bytes.empty

    getter fh : UInt64 { backend.fh_new }

    def read(size, offset) : Bytes
# BUG: finish
      if offset == 0
        "foo".to_slice
      else
        return Bytes.empty
      end
    end

    def write(buf : Bytes, offset) : Int32
      
      buf.bytesize
    end

    def release : Nil
      backend.open_file_handles.delete fh

Log.info &.emit("open_file_handles", h: backend.open_file_handles.keys.inspect)
    end
  end

  class MyOpenDir < Fuse::MidLevel::Open::Dir
    getter fh : UInt64 { backend.fh_new }

    def releasedir : Nil
      backend.open_dir_handles.delete fh
Log.info &.emit("open_dir_handles", h: backend.open_dir_handles.keys.inspect)
    end
  end

  class MyFile < Fuse::MidLevel::Inode::File
    def open(fi) : UInt64
      of = MyOpenFile.new self
      backend.open_file_handles[of.fh] = of
Log.info { "open fh=#{of.fh.inspect}" }
      of.fh
    end

    def st_size
      5
#     data.bytesize
    end

#   def forget(nlookup) : Nil
#   end
  end

  class MyDir < Fuse::MidLevel::Inode::Dir
    getter children = {} of String => UInt64

    def opendir(fi) : UInt64
      od = MyOpenDir.new self
      @backend.open_dir_handles[od.fh] = od
Log.info { "opendir fh=#{od.fh.inspect}" }
      od.fh
    end


    def create_file(name, mode, fi) : Fuse::MidLevel::Open::File
      finode = MyFile.new @backend, @backend.inum_new
      fhandle = MyOpenFile.new finode
#     MyOpenFile.new ?
raise "not fin"
    end

#   def each_child
#   end

    def file_add(name : String) : Nil
      finode = MyFile.new @backend, @backend.inum_new
      fhandle = MyOpenFile.new finode
      yield fhandle
      @children[name] = finode.ino
      @backend.inode_add finode
    end

    def mkdir(name : String) : MyDir
      dir = MyDir.new @backend, @backend.inum_new
      @children[name] = dir.ino
      @backend.inode_add dir
      dir
    end
  end

  @@inum = Atomic(UInt64).new 1 # 0 Fuse reserved
  @@fh = Atomic(UInt64).new 1

  getter open_file_handles = {} of UInt64 => MyOpenFile
  getter open_dir_handles = {} of UInt64 => MyOpenDir

  def initialize
    @inodes[root.ino] = root

    root.file_add "foo" do |open_file|
      open_file = open_file.as MyOpenFile
#     file = file.as MyFile
      open_file.data = "foo data".to_slice
    end
    bar = root.mkdir "bar"
  end

  def inum_new : UInt64
    @@inum.add 1
  end

  def fh_new : UInt64
    @@fh.add 1
  end

  def inode_add(inode)
Log.notice &.emit("inode_add", ino: inode.ino.to_i)
    @inodes[inode.ino] = inode
  end

# getter root : Fuse::MidLevel::Inode::Dir { MyDir.new inum_new }
  getter root : MyDir { MyDir.new self, inum_new }

  def post_init
    super

  end
end

class MyFs < Fuse::MidLevel::Fs
#class MyFs < Fuse::MidLevel::Fs(MyFile, MyDir)
  def post_init
    super
  end
end

backend = MyBackend.new
fs = MyFs.new backend
fs.post_init # sets @root

handler = Fuse::MidLevel::Handler.new fs
handler.run!

