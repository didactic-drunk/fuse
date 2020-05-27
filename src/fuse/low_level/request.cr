struct Fuse::LowLevel::Request
  Log = ::Log.for self

  def initialize(@ptr : Lib::FuseReqT)
  end

  def low_level
    user_data.as LowLevel
  end

  private def user_data
    Lib.req_userdata(self)
  end

# def context
# const struct fuse_ctx *fuse_req_ctx(fuse_req_t req);
# end

  # Reqs: getattr, setattr
  #
  #
  def reply_attr(attr : LibC::Stat) : Nil
Log.info &.emit("reply_attr", attr: attr.inspect)
    e = Lib.reply_attr self, pointerof(attr), 1.0
    check_errno "reply_attr", e
  end

  def reply_none : Nil
Log.info &.emit("reply_none")
    Lib.reply_none self
  end

# void fuse_reply_none(fuse_req_t req); forget
# int fuse_reply_xtimes(fuse_req_t req, const struct timespec *bkuptime,
#         const struct timespec *crtime);

  # Reply with a directory entry
  #
  # Reqs: lookup, mknod, mkdir, symlink, link
  #
  # Side effects: increments the lookup count on success
  #
  # Duck typed inode.  Must respond to [ino, st_mode, st_nlink, st_size]
  def reply_entry(inode, *, attr_timeout = 1.0, entry_timeout = 1.0) : Nil
    fep = Lib::FuseEntryParam.new
    fep.ino = inode.ino
    fep.attr_timeout = attr_timeout
    fep.entry_timeout = entry_timeout
    fep.attr.st_ino = inode.ino
    fep.attr.st_mode = inode.st_mode
    fep.attr.st_nlink = inode.st_nlink
    fep.attr.st_size = inode.st_size

    Log.debug &.emit("reply_entry", ino: inode.ino.to_i, mode: fep.attr.st_mode.to_i)

    e = Lib.reply_entry self, pointerof(fep)
    check_errno "reply_entry", e
  end

  def reply_buf(buf : Bytes) : Nil
Log.info &.emit("reply_buf", size: buf.bytesize)
    e = Lib.reply_buf self, buf, buf.bytesize
    check_errno "reply_buf", e
  end

# Reply with a directory entry and open parameters
# currently the following members of 'fi' are used: fh, direct_io, keep_cache
# create
# increments the lookup count on success
#int fuse_reply_create(fuse_req_t req, const struct fuse_entry_param *e,
#         const struct fuse_file_info *fi);


# int fuse_reply_readlink(fuse_req_t req, const char *link);
# readlink

  # Reply with open parameters
  #
  # Reqs: open, opendir
  #
  # currently the following members of 'fi' are used: fh, direct_io, keep_cache
  def reply_open(fi : Lib::FuseFileInfo*) : Nil
Log.info &.emit("reply_open", fi: (fi.null? ? nil : fi.value.inspect), fip: fi.inspect)
    e = Lib.reply_open self, fi
    check_errno "reply_open", e
  end

  def reply_write(count) : Nil
Log.info &.emit("reply_write", count: count.to_i)
    e = Lib.reply_write self, count.to_u64
    check_errno "reply_write", e
  end


# write
# int fuse_reply_write(fuse_req_t req, size_t count);

# read, readdir, getxattr, listxattr
# int fuse_reply_buf(fuse_req_t req, const char *buf, size_t size);

# read, readdir, getxattr, listxattr
# int fuse_reply_data(fuse_req_t req, struct fuse_bufvec *bufv,
#       enum fuse_buf_copy_flags flags);

# read, readdir, getxattr, listxattr
# int fuse_reply_iov(fuse_req_t req, const struct iovec *iov, int count);

# statfs
# int fuse_reply_statfs(fuse_req_t req, const struct statvfs *stbuf);
# apple
# int fuse_reply_statfs_x(fuse_req_t req, const struct statfs *stbuf);


# Reply with needed buffer size
# getxattr, listxattr
# int fuse_reply_xattr(fuse_req_t req, size_t count);


# Add a directory entry to the buffer
# size_t fuse_add_direntry(fuse_req_t req, char *buf, size_t bufsize,
#      const char *name, const struct stat *stbuf,
#      off_t off);

# * Notify to invalidate cache for an inode
#int fuse_lowlevel_notify_inval_inode(struct fuse_chan *ch, fuse_ino_t ino,
#                                     off_t off, off_t len);

# Notify to invalidate parent attributes and the dentry matching parent/name
# int fuse_lowlevel_notify_inval_entry(struct fuse_chan *ch, fuse_ino_t parent,
#                                     const char *name, size_t namelen);

# Notify to invalidate parent attributes and delete the dentry matching parent/name if the dentry's inode number matches child (otherwise it will invalidate the matching dentry).
# int fuse_lowlevel_notify_delete(struct fuse_chan *ch,
#       fuse_ino_t parent, fuse_ino_t child,
#       const char *name, size_t namelen);

# int fuse_lowlevel_notify_store(struct fuse_chan *ch, fuse_ino_t ino,
#            off_t offset, struct fuse_bufvec *bufv,
#            enum fuse_buf_copy_flags flags);

# int fuse_lowlevel_notify_retrieve(struct fuse_chan *ch, fuse_ino_t ino,
#         size_t size, off_t offset, void *cookie);




  def reply_err(ex : Exception) : Nil
    err = if ex.responds_to? :errno
      ex.errno
    else
      Errno::EDQUOT
    end

    reply_err err
  end

  def reply_err(err : Errno) : Nil
Log.info &.emit("reply_err", v: err.value)
    e = Lib.reply_err self, err.value
    check_errno "reply_err", e
  end

  def unsupported
    Log.warn &.emit("reply unsupported")
    reply_err Errno::EOPNOTSUPP # Not sup on socket
  end

  private def check_errno(msg, e)
    raise msg unless e == 0
  end

  # :nodoc:
  def to_unsafe
    @ptr
  end
end
