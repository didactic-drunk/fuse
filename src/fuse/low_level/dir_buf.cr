class Fuse::LowLevel::DirBuf
  Log = ::Log.for self

  @limit : Int32 = 0
  getter size : Int32 = 0

  def initialize(@req : Request, limit)
    @limit = limit.to_i
    @buf = Bytes.new @limit
    @idx = 1 # 0 Reserved
  end

  def add(name : String, ino, mode) : Nil
# fuse_add_direntry(req : FuseReqT, buf : LibC::Char*, bufsize : LibC::SizeT, name : LibC::Char*, stbuf : LibC::Stat*, off : OffT) : LibC::SizeT
    add_size = Lib.add_direntry @req, nil, 0, name, nil, 0

    Log.info &.emit("add_direntry", name: name, ino: ino.to_i, mode: mode, add_size: add_size.to_i)
    new_size = @size + add_size
    remaining = @limit - @size
    raise "size too big new_size=#{new_size} remaining=#{remaining}" if new_size > remaining

    stat = LibC::Stat.new
    stat.st_ino = ino
    stat.st_mode = mode
    Lib.add_direntry @req, @buf[@size, remaining], remaining, name, pointerof(stat), @idx
    @idx += 1
    @size = new_size
  end

  def to_slice : Bytes
    @buf[0, @size]
  end

  def reset : Nil
    @idx = 1
    @size = 0
  end
end
