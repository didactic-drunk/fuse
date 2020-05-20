module Fuse; @[Link(ldflags: "`command -v pkg-config > /dev/null && pkg-config --libs fuse 2> /dev/null|| printf %s '-lfuse'`")]
lib Lib
  alias BlkcntT = X__DarwinBlkcntT
  alias BlksizeT = X__DarwinBlksizeT
  alias DevT = X__DarwinDevT
  alias FsblkcntT = X__DarwinFsblkcntT
  alias FsfilcntT = X__DarwinFsfilcntT
  alias Fuse = Void
  alias FuseChan = Void
  alias FuseCmd = Void
  alias FuseDirfilT = (FuseDirhT, LibC::Char*, LibC::Int, InoT -> LibC::Int)
  alias FuseDirhandle = Void
  alias FillDirT = (Void*, LibC::Char*, LibC::Stat*, OffT -> LibC::Int)
  alias FuseFs = Void
  alias FuseInoT = LibC::ULong
  alias FuseInterruptFuncT = (FuseReqT, Void* -> Void)
  alias FuseOptProcT = (Void*, LibC::Char*, LibC::Int, FuseArgs* -> LibC::Int)
  alias FusePollhandle = Void
  alias FuseProcessorT = (Fuse*, FuseCmd*, Void* -> Void)
  alias FuseReq = Void
  alias Session = Void
  alias GidT = X__DarwinGidT
  alias InoT = X__DarwinInoT
  alias Int32T = LibC::Int
  alias ModeT = X__DarwinModeT
  alias NlinkT = X__Uint16T
  alias OffT = X__DarwinOffT
  alias PidT = X__DarwinPidT
  alias SsizeT = X__DarwinSsizeT
  alias TimeT = X__DarwinTimeT
  alias UidT = X__DarwinUidT
  alias Uint32T = LibC::UInt
  alias Uint64T = LibC::ULongLong
  alias X__DarwinBlkcntT = X__Int64T
  alias X__DarwinBlksizeT = X__Int32T
  alias X__DarwinDevT = X__Int32T
  alias X__DarwinFsblkcntT = LibC::UInt
  alias X__DarwinFsfilcntT = LibC::UInt
  alias X__DarwinGidT = X__Uint32T
  alias X__DarwinIno64T = X__Uint64T
  alias X__DarwinInoT = X__DarwinIno64T
  alias X__DarwinModeT = X__Uint16T
  alias X__DarwinOffT = X__Int64T
  alias X__DarwinPidT = X__Int32T
  alias X__DarwinSsizeT = LibC::Long
  alias X__DarwinTimeT = LibC::Long
  alias X__DarwinUidT = X__Uint32T
  alias X__Int32T = LibC::Int
  alias X__Int64T = LibC::LongLong
  alias X__Uint16T = LibC::UShort
  alias X__Uint32T = LibC::UInt
  alias X__Uint64T = LibC::ULongLong
  enum FuseBufCopyFlags
    FuseBufNoSplice       =  2
    FuseBufForceSplice    =  4
    FuseBufSpliceMove     =  8
    FuseBufSpliceNonblock = 16
  end
  enum FuseBufFlags
    FuseBufIsFd    = 2
    FuseBufFdSeek  = 4
    FuseBufFdRetry = 8
  end
  fun add_dirent = fuse_add_dirent(buf : LibC::Char*, name : LibC::Char*, stbuf : LibC::Stat*, off : OffT) : LibC::Char*
  fun add_direntry = fuse_add_direntry(req : FuseReqT, buf : LibC::Char*, bufsize : LibC::SizeT, name : LibC::Char*, stbuf : LibC::Stat*, off : OffT) : LibC::SizeT
  fun buf_copy = fuse_buf_copy(dst : FuseBufvec*, src : FuseBufvec*, flags : FuseBufCopyFlags) : SsizeT
  fun buf_size = fuse_buf_size(bufv : FuseBufvec*) : LibC::SizeT
  fun chan_bufsize = fuse_chan_bufsize(ch : FuseChan*) : LibC::SizeT
  fun chan_data = fuse_chan_data(ch : FuseChan*) : Void*
  fun chan_destroy = fuse_chan_destroy(ch : FuseChan*)
  fun chan_fd = fuse_chan_fd(ch : FuseChan*) : LibC::Int
  fun chan_new = fuse_chan_new(op : FuseChanOps*, fd : LibC::Int, bufsize : LibC::SizeT, data : Void*) : FuseChan*
  fun chan_new_compat24 = fuse_chan_new_compat24(op : FuseChanOpsCompat24*, fd : LibC::Int, bufsize : LibC::SizeT, data : Void*) : FuseChan*
  fun chan_receive = fuse_chan_receive(ch : FuseChan*, buf : LibC::Char*, size : LibC::SizeT) : LibC::Int
  fun chan_recv = fuse_chan_recv(ch : FuseChan**, buf : LibC::Char*, size : LibC::SizeT) : LibC::Int
  fun chan_send = fuse_chan_send(ch : FuseChan*, iov : Iovec*, count : LibC::SizeT) : LibC::Int
  fun chan_session = fuse_chan_session(ch : FuseChan*) : Session*
  fun clean_cache = fuse_clean_cache(fuse : Fuse*) : LibC::Int
  fun daemonize = fuse_daemonize(foreground : LibC::Int) : LibC::Int
  fun destroy = fuse_destroy(f : Fuse*)
  fun dirent_size = fuse_dirent_size(namelen : LibC::SizeT) : LibC::SizeT
  fun exit = fuse_exit(f : Fuse*)
  fun exited = fuse_exited(f : Fuse*) : LibC::Int
  fun fs_access = fuse_fs_access(fs : FuseFs*, path : LibC::Char*, mask : LibC::Int) : LibC::Int
  fun fs_bmap = fuse_fs_bmap(fs : FuseFs*, path : LibC::Char*, blocksize : LibC::SizeT, idx : Uint64T*) : LibC::Int
  fun fs_chflags = fuse_fs_chflags(fs : FuseFs*, path : LibC::Char*, flags : Uint32T) : LibC::Int
  fun fs_chmod = fuse_fs_chmod(fs : FuseFs*, path : LibC::Char*, mode : ModeT) : LibC::Int
  fun fs_chown = fuse_fs_chown(fs : FuseFs*, path : LibC::Char*, uid : UidT, gid : GidT) : LibC::Int
  fun fs_create = fuse_fs_create(fs : FuseFs*, path : LibC::Char*, mode : ModeT, fi : FuseFileInfo*) : LibC::Int
  fun fs_destroy = fuse_fs_destroy(fs : FuseFs*)
  fun fs_exchange = fuse_fs_exchange(fs : FuseFs*, oldpath : LibC::Char*, newpath : LibC::Char*, flags : LibC::ULong) : LibC::Int
  fun fs_fallocate = fuse_fs_fallocate(fs : FuseFs*, path : LibC::Char*, mode : LibC::Int, offset : OffT, length : OffT, fi : FuseFileInfo*) : LibC::Int
  fun fs_fgetattr = fuse_fs_fgetattr(fs : FuseFs*, path : LibC::Char*, buf : LibC::Stat*, fi : FuseFileInfo*) : LibC::Int
  fun fs_flock = fuse_fs_flock(fs : FuseFs*, path : LibC::Char*, fi : FuseFileInfo*, op : LibC::Int) : LibC::Int
  fun fs_flush = fuse_fs_flush(fs : FuseFs*, path : LibC::Char*, fi : FuseFileInfo*) : LibC::Int
  fun fs_fsetattr_x = fuse_fs_fsetattr_x(fs : FuseFs*, path : LibC::Char*, attr : SetattrX*, fi : FuseFileInfo*) : LibC::Int
  fun fs_fsync = fuse_fs_fsync(fs : FuseFs*, path : LibC::Char*, datasync : LibC::Int, fi : FuseFileInfo*) : LibC::Int
  fun fs_fsyncdir = fuse_fs_fsyncdir(fs : FuseFs*, path : LibC::Char*, datasync : LibC::Int, fi : FuseFileInfo*) : LibC::Int
  fun fs_ftruncate = fuse_fs_ftruncate(fs : FuseFs*, path : LibC::Char*, size : OffT, fi : FuseFileInfo*) : LibC::Int
  fun fs_getattr = fuse_fs_getattr(fs : FuseFs*, path : LibC::Char*, buf : LibC::Stat*) : LibC::Int
  fun fs_getxattr = fuse_fs_getxattr(fs : FuseFs*, path : LibC::Char*, name : LibC::Char*, value : LibC::Char*, size : LibC::SizeT, position : Uint32T) : LibC::Int
  fun fs_getxtimes = fuse_fs_getxtimes(fs : FuseFs*, path : LibC::Char*, bkuptime : Timespec*, crtime : Timespec*) : LibC::Int
  fun fs_init = fuse_fs_init(fs : FuseFs*, conn : FuseConnInfo*)
  fun fs_ioctl = fuse_fs_ioctl(fs : FuseFs*, path : LibC::Char*, cmd : LibC::Int, arg : Void*, fi : FuseFileInfo*, flags : LibC::UInt, data : Void*) : LibC::Int
  fun fs_link = fuse_fs_link(fs : FuseFs*, oldpath : LibC::Char*, newpath : LibC::Char*) : LibC::Int
  fun fs_listxattr = fuse_fs_listxattr(fs : FuseFs*, path : LibC::Char*, list : LibC::Char*, size : LibC::SizeT) : LibC::Int
  fun fs_lock = fuse_fs_lock(fs : FuseFs*, path : LibC::Char*, fi : FuseFileInfo*, cmd : LibC::Int, lock : Flock*) : LibC::Int
  fun fs_mkdir = fuse_fs_mkdir(fs : FuseFs*, path : LibC::Char*, mode : ModeT) : LibC::Int
  fun fs_mknod = fuse_fs_mknod(fs : FuseFs*, path : LibC::Char*, mode : ModeT, rdev : DevT) : LibC::Int
  fun fs_new = fuse_fs_new(op : Operations*, op_size : LibC::SizeT, user_data : Void*) : FuseFs*
  fun fs_open = fuse_fs_open(fs : FuseFs*, path : LibC::Char*, fi : FuseFileInfo*) : LibC::Int
  fun fs_opendir = fuse_fs_opendir(fs : FuseFs*, path : LibC::Char*, fi : FuseFileInfo*) : LibC::Int
  fun fs_poll = fuse_fs_poll(fs : FuseFs*, path : LibC::Char*, fi : FuseFileInfo*, ph : FusePollhandle*, reventsp : LibC::UInt*) : LibC::Int
  fun fs_read = fuse_fs_read(fs : FuseFs*, path : LibC::Char*, buf : LibC::Char*, size : LibC::SizeT, off : OffT, fi : FuseFileInfo*) : LibC::Int
  fun fs_read_buf = fuse_fs_read_buf(fs : FuseFs*, path : LibC::Char*, bufp : FuseBufvec**, size : LibC::SizeT, off : OffT, fi : FuseFileInfo*) : LibC::Int
  fun fs_readdir = fuse_fs_readdir(fs : FuseFs*, path : LibC::Char*, buf : Void*, filler : FillDirT, off : OffT, fi : FuseFileInfo*) : LibC::Int
  fun fs_readlink = fuse_fs_readlink(fs : FuseFs*, path : LibC::Char*, buf : LibC::Char*, len : LibC::SizeT) : LibC::Int
  fun fs_release = fuse_fs_release(fs : FuseFs*, path : LibC::Char*, fi : FuseFileInfo*) : LibC::Int
  fun fs_releasedir = fuse_fs_releasedir(fs : FuseFs*, path : LibC::Char*, fi : FuseFileInfo*) : LibC::Int
  fun fs_removexattr = fuse_fs_removexattr(fs : FuseFs*, path : LibC::Char*, name : LibC::Char*) : LibC::Int
  fun fs_rename = fuse_fs_rename(fs : FuseFs*, oldpath : LibC::Char*, newpath : LibC::Char*) : LibC::Int
  fun fs_rmdir = fuse_fs_rmdir(fs : FuseFs*, path : LibC::Char*) : LibC::Int
  fun fs_setattr_x = fuse_fs_setattr_x(fs : FuseFs*, path : LibC::Char*, attr : SetattrX*) : LibC::Int
  fun fs_setbkuptime = fuse_fs_setbkuptime(fs : FuseFs*, path : LibC::Char*, tv : Timespec*) : LibC::Int
  fun fs_setchgtime = fuse_fs_setchgtime(fs : FuseFs*, path : LibC::Char*, tv : Timespec*) : LibC::Int
  fun fs_setcrtime = fuse_fs_setcrtime(fs : FuseFs*, path : LibC::Char*, tv : Timespec*) : LibC::Int
  fun fs_setvolname = fuse_fs_setvolname(fs : FuseFs*, volname : LibC::Char*) : LibC::Int
  fun fs_setxattr = fuse_fs_setxattr(fs : FuseFs*, path : LibC::Char*, name : LibC::Char*, value : LibC::Char*, size : LibC::SizeT, flags : LibC::Int, position : Uint32T) : LibC::Int
  fun fs_statfs = fuse_fs_statfs(fs : FuseFs*, path : LibC::Char*, buf : Statvfs*) : LibC::Int
  fun fs_statfs_x = fuse_fs_statfs_x(fs : FuseFs*, path : LibC::Char*, buf : Statfs*) : LibC::Int
  fun fs_symlink = fuse_fs_symlink(fs : FuseFs*, linkname : LibC::Char*, path : LibC::Char*) : LibC::Int
  fun fs_truncate = fuse_fs_truncate(fs : FuseFs*, path : LibC::Char*, size : OffT) : LibC::Int
  fun fs_unlink = fuse_fs_unlink(fs : FuseFs*, path : LibC::Char*) : LibC::Int
  fun fs_utimens = fuse_fs_utimens(fs : FuseFs*, path : LibC::Char*, tv : Timespec[2]) : LibC::Int
  fun fs_write = fuse_fs_write(fs : FuseFs*, path : LibC::Char*, buf : LibC::Char*, size : LibC::SizeT, off : OffT, fi : FuseFileInfo*) : LibC::Int
  fun fs_write_buf = fuse_fs_write_buf(fs : FuseFs*, path : LibC::Char*, buf : FuseBufvec*, off : OffT, fi : FuseFileInfo*) : LibC::Int
  fun get_context = fuse_get_context : Context*
  fun get_session = fuse_get_session(f : Fuse*) : Session*
  fun getgroups = fuse_getgroups(size : LibC::Int, list : GidT*) : LibC::Int
  fun interrupted = fuse_interrupted : LibC::Int
  fun invalidate = fuse_invalidate(f : Fuse*, path : LibC::Char*) : LibC::Int
  fun invalidate_path = fuse_invalidate_path(f : Fuse*, path : LibC::Char*) : LibC::Int
  fun is_lib_option = fuse_is_lib_option(opt : LibC::Char*) : LibC::Int
  fun kern_chan_new = fuse_kern_chan_new(fd : LibC::Int) : FuseChan*
  fun loop = fuse_loop(f : Fuse*) : LibC::Int
  fun loop_mt = fuse_loop_mt(f : Fuse*) : LibC::Int
  fun loop_mt_proc = fuse_loop_mt_proc(f : Fuse*, proc : FuseProcessorT, data : Void*) : LibC::Int
  fun lowlevel_is_lib_option = fuse_lowlevel_is_lib_option(opt : LibC::Char*) : LibC::Int
  fun lowlevel_new = fuse_lowlevel_new(args : FuseArgs*, op : FuseLowlevelOps*, op_size : LibC::SizeT, userdata : Void*) : Session*
  fun lowlevel_new_compat25 = fuse_lowlevel_new_compat25(args : FuseArgs*, op : FuseLowlevelOpsCompat25*, op_size : LibC::SizeT, userdata : Void*) : Session*
  fun lowlevel_notify_delete = fuse_lowlevel_notify_delete(ch : FuseChan*, parent : FuseInoT, child : FuseInoT, name : LibC::Char*, namelen : LibC::SizeT) : LibC::Int
  fun lowlevel_notify_inval_entry = fuse_lowlevel_notify_inval_entry(ch : FuseChan*, parent : FuseInoT, name : LibC::Char*, namelen : LibC::SizeT) : LibC::Int
  fun lowlevel_notify_inval_inode = fuse_lowlevel_notify_inval_inode(ch : FuseChan*, ino : FuseInoT, off : OffT, len : OffT) : LibC::Int
  fun lowlevel_notify_poll = fuse_lowlevel_notify_poll(ph : FusePollhandle*) : LibC::Int
  fun lowlevel_notify_retrieve = fuse_lowlevel_notify_retrieve(ch : FuseChan*, ino : FuseInoT, size : LibC::SizeT, offset : OffT, cookie : Void*) : LibC::Int
  fun lowlevel_notify_store = fuse_lowlevel_notify_store(ch : FuseChan*, ino : FuseInoT, offset : OffT, bufv : FuseBufvec*, flags : FuseBufCopyFlags) : LibC::Int
  fun main_real = fuse_main_real(argc : LibC::Int, argv : LibC::Char**, op : Operations*, op_size : LibC::SizeT, user_data : Void*) : LibC::Int
  fun main_real_compat25 = fuse_main_real_compat25(argc : LibC::Int, argv : LibC::Char**, op : OperationsCompat25*, op_size : LibC::SizeT) : LibC::Int
  fun mount = fuse_mount(mountpoint : LibC::Char*, args : FuseArgs*) : FuseChan*
  fun mount_compat1 = fuse_mount_compat1(mountpoint : LibC::Char*, args : LibC::Char**) : LibC::Int
  fun mount_compat22 = fuse_mount_compat22(mountpoint : LibC::Char*, opts : LibC::Char*) : LibC::Int
  fun mount_compat25 = fuse_mount_compat25(mountpoint : LibC::Char*, args : FuseArgs*) : LibC::Int
  fun new = fuse_new(ch : FuseChan*, args : FuseArgs*, op : Operations*, op_size : LibC::SizeT, user_data : Void*) : Fuse*
  fun new_compat25 = fuse_new_compat25(fd : LibC::Int, args : FuseArgs*, op : OperationsCompat25*, op_size : LibC::SizeT) : Fuse*
  fun notify_poll = fuse_notify_poll(ph : FusePollhandle*) : LibC::Int
  fun opt_add_arg = fuse_opt_add_arg(args : FuseArgs*, arg : LibC::Char*) : LibC::Int
  fun opt_add_opt = fuse_opt_add_opt(opts : LibC::Char**, opt : LibC::Char*) : LibC::Int
  fun opt_add_opt_escaped = fuse_opt_add_opt_escaped(opts : LibC::Char**, opt : LibC::Char*) : LibC::Int
  fun opt_free_args = fuse_opt_free_args(args : FuseArgs*)
  fun opt_insert_arg = fuse_opt_insert_arg(args : FuseArgs*, pos : LibC::Int, arg : LibC::Char*) : LibC::Int
  fun opt_match = fuse_opt_match(opts : FuseOpt*, opt : LibC::Char*) : LibC::Int
  fun opt_parse = fuse_opt_parse(args : FuseArgs*, data : Void*, opts : FuseOpt*, proc : FuseOptProcT) : LibC::Int
  fun parse_cmdline = fuse_parse_cmdline(args : FuseArgs*, mountpoint : LibC::Char**, multithreaded : LibC::Int*, foreground : LibC::Int*) : LibC::Int
  fun pollhandle_destroy = fuse_pollhandle_destroy(ph : FusePollhandle*)
  fun process_cmd = fuse_process_cmd(f : Fuse*, cmd : FuseCmd*)
  fun read_cmd = fuse_read_cmd(f : Fuse*) : FuseCmd*
  fun register_module = fuse_register_module(mod : FuseModule*)
  fun remove_signal_handlers = fuse_remove_signal_handlers(se : Session*)
  fun reply_attr = fuse_reply_attr(req : FuseReqT, attr : LibC::Stat*, attr_timeout : LibC::Double) : LibC::Int
  fun reply_bmap = fuse_reply_bmap(req : FuseReqT, idx : Uint64T) : LibC::Int
  fun reply_buf = fuse_reply_buf(req : FuseReqT, buf : LibC::Char*, size : LibC::SizeT) : LibC::Int
  fun reply_create = fuse_reply_create(req : FuseReqT, e : FuseEntryParam*, fi : FuseFileInfo*) : LibC::Int
  fun reply_data = fuse_reply_data(req : FuseReqT, bufv : FuseBufvec*, flags : FuseBufCopyFlags) : LibC::Int
  fun reply_entry = fuse_reply_entry(req : FuseReqT, e : FuseEntryParam*) : LibC::Int
  fun reply_err = fuse_reply_err(req : FuseReqT, err : LibC::Int) : LibC::Int
  fun reply_ioctl = fuse_reply_ioctl(req : FuseReqT, result : LibC::Int, buf : Void*, size : LibC::SizeT) : LibC::Int
  fun reply_ioctl_iov = fuse_reply_ioctl_iov(req : FuseReqT, result : LibC::Int, iov : Iovec*, count : LibC::Int) : LibC::Int
  fun reply_ioctl_retry = fuse_reply_ioctl_retry(req : FuseReqT, in_iov : Iovec*, in_count : LibC::SizeT, out_iov : Iovec*, out_count : LibC::SizeT) : LibC::Int
  fun reply_iov = fuse_reply_iov(req : FuseReqT, iov : Iovec*, count : LibC::Int) : LibC::Int
  fun reply_lock = fuse_reply_lock(req : FuseReqT, lock : Flock*) : LibC::Int
  fun reply_none = fuse_reply_none(req : FuseReqT)
  fun reply_open = fuse_reply_open(req : FuseReqT, fi : FuseFileInfo*) : LibC::Int
  fun reply_poll = fuse_reply_poll(req : FuseReqT, revents : LibC::UInt) : LibC::Int
  fun reply_readlink = fuse_reply_readlink(req : FuseReqT, link : LibC::Char*) : LibC::Int
  fun reply_statfs = fuse_reply_statfs(req : FuseReqT, stbuf : Statvfs*) : LibC::Int
  fun reply_statfs_x = fuse_reply_statfs_x(req : FuseReqT, stbuf : Statfs*) : LibC::Int
  fun reply_write = fuse_reply_write(req : FuseReqT, count : LibC::SizeT) : LibC::Int
  fun reply_xattr = fuse_reply_xattr(req : FuseReqT, count : LibC::SizeT) : LibC::Int
  fun reply_xtimes = fuse_reply_xtimes(req : FuseReqT, bkuptime : Timespec*, crtime : Timespec*) : LibC::Int
  fun req_ctx = fuse_req_ctx(req : FuseReqT) : FuseCtx*
  fun req_getgroups = fuse_req_getgroups(req : FuseReqT, size : LibC::Int, list : GidT*) : LibC::Int
  fun req_interrupt_func = fuse_req_interrupt_func(req : FuseReqT, func : FuseInterruptFuncT, data : Void*)
  fun req_interrupted = fuse_req_interrupted(req : FuseReqT) : LibC::Int
  fun req_userdata = fuse_req_userdata(req : FuseReqT) : Void*
  fun session_add_chan = fuse_session_add_chan(se : Session*, ch : FuseChan*)
  fun session_data = fuse_session_data(se : Session*) : Void*
  fun session_destroy = fuse_session_destroy(se : Session*)
  fun session_exit = fuse_session_exit(se : Session*)
  fun session_exited = fuse_session_exited(se : Session*) : LibC::Int
  fun session_loop = fuse_session_loop(se : Session*) : LibC::Int
  fun session_loop_mt = fuse_session_loop_mt(se : Session*) : LibC::Int
  fun session_new = fuse_session_new(op : SessionOps*, data : Void*) : Session*
  fun session_next_chan = fuse_session_next_chan(se : Session*, ch : FuseChan*) : FuseChan*
  fun session_process = fuse_session_process(se : Session*, buf : LibC::Char*, len : LibC::SizeT, ch : FuseChan*)
  fun session_process_buf = fuse_session_process_buf(se : Session*, buf : FuseBuf*, ch : FuseChan*)
  fun session_receive_buf = fuse_session_receive_buf(se : Session*, buf : FuseBuf*, chp : FuseChan**) : LibC::Int
  fun session_remove_chan = fuse_session_remove_chan(ch : FuseChan*)
  fun session_reset = fuse_session_reset(se : Session*)
  fun set_getcontext_func = fuse_set_getcontext_func(func : (-> Context*))
  fun set_signal_handlers = fuse_set_signal_handlers(se : Session*) : LibC::Int
  fun setup = fuse_setup(argc : LibC::Int, argv : LibC::Char**, op : Operations*, op_size : LibC::SizeT, mountpoint : LibC::Char**, multithreaded : LibC::Int*, user_data : Void*) : Fuse*
  fun setup_compat25 = fuse_setup_compat25(argc : LibC::Int, argv : LibC::Char**, op : OperationsCompat25*, op_size : LibC::SizeT, mountpoint : LibC::Char**, multithreaded : LibC::Int*, fd : LibC::Int*) : Fuse*
  fun start_cleanup_thread = fuse_start_cleanup_thread(fuse : Fuse*) : LibC::Int
  fun stop_cleanup_thread = fuse_stop_cleanup_thread(fuse : Fuse*)
  fun teardown = fuse_teardown(fuse : Fuse*, mountpoint : LibC::Char*)
  fun teardown_compat22 = fuse_teardown_compat22(fuse : Fuse*, fd : LibC::Int, mountpoint : LibC::Char*)
  fun unmount = fuse_unmount(mountpoint : LibC::Char*, ch : FuseChan*)
  fun unmount_compat22 = fuse_unmount_compat22(mountpoint : LibC::Char*)
  fun version = fuse_version : LibC::Int

  struct Flock
    l_start : OffT
    l_len : OffT
    l_pid : PidT
    l_type : LibC::Short
    l_whence : LibC::Short
  end

  struct Fsid
    val : Int32T[2]
  end

  struct FuseArgs
    argc : LibC::Int
    argv : LibC::Char**
    allocated : LibC::Int
  end

  struct FuseBuf
    size : LibC::SizeT
    flags : FuseBufFlags
    mem : Void*
    fd : LibC::Int
    pos : OffT
  end

  struct FuseBufvec
    count : LibC::SizeT
    idx : LibC::SizeT
    off : LibC::SizeT
    buf : FuseBuf[1]
  end

  struct FuseChanOps
    receive : (FuseChan**, LibC::Char*, LibC::SizeT -> LibC::Int)
    send : (FuseChan*, Iovec*, LibC::SizeT -> LibC::Int)
    destroy : (FuseChan* -> Void)
  end

  struct FuseChanOpsCompat24
    receive : (FuseChan*, LibC::Char*, LibC::SizeT -> LibC::Int)
    send : (FuseChan*, Iovec*, LibC::SizeT -> LibC::Int)
    destroy : (FuseChan* -> Void)
  end

  struct FuseConnInfo
    proto_major : LibC::UInt
    proto_minor : LibC::UInt
    async_read : LibC::UInt
    max_write : LibC::UInt
    max_readahead : LibC::UInt
    enable : FuseConnInfoEnable
    capable : LibC::UInt
    want : LibC::UInt
    max_background : LibC::UInt
    congestion_threshold : LibC::UInt
    reserved : LibC::UInt[22]
  end

  struct FuseConnInfoEnable
    case_insensitive : LibC::UInt
    setvolname : LibC::UInt
    xtimes : LibC::UInt
  end

  struct Context
    fuse : Fuse*
    uid : UidT
    gid : GidT
    pid : PidT
    private_data : Void*
    umask : ModeT
  end

  struct FuseCtx
    uid : UidT
    gid : GidT
    pid : PidT
    umask : ModeT
  end

  struct FuseEntryParam
    ino : FuseInoT
    generation : LibC::ULong
    attr : Stat
    attr_timeout : LibC::Double
    entry_timeout : LibC::Double
  end

  struct FuseFileInfo
    flags : LibC::Int
    fh_old : LibC::ULong
    writepage : LibC::Int
    direct_io : LibC::UInt
    keep_cache : LibC::UInt
    flush : LibC::UInt
    nonseekable : LibC::UInt
    flock_release : LibC::UInt
    padding : LibC::UInt
    purge_attr : LibC::UInt
    purge_ubc : LibC::UInt
    fh : Uint64T
    lock_owner : Uint64T
  end

  struct FuseFileInfoCompat
    flags : LibC::Int
    fh : LibC::ULong
    writepage : LibC::Int
    direct_io : LibC::UInt
    keep_cache : LibC::UInt
  end

  struct FuseForgetData
    ino : Uint64T
    nlookup : Uint64T
  end

  struct FuseLowlevelOps
    init : (Void*, FuseConnInfo* -> Void)
    destroy : (Void* -> Void)
    lookup : (FuseReqT, FuseInoT, LibC::Char* -> Void)
    forget : (FuseReqT, FuseInoT, LibC::ULong -> Void)
    getattr : (FuseReqT, FuseInoT, FuseFileInfo* -> Void)
    setattr : (FuseReqT, FuseInoT, LibC::Stat*, LibC::Int, FuseFileInfo* -> Void)
    readlink : (FuseReqT, FuseInoT -> Void)
    mknod : (FuseReqT, FuseInoT, LibC::Char*, ModeT, DevT -> Void)
    mkdir : (FuseReqT, FuseInoT, LibC::Char*, ModeT -> Void)
    unlink : (FuseReqT, FuseInoT, LibC::Char* -> Void)
    rmdir : (FuseReqT, FuseInoT, LibC::Char* -> Void)
    symlink : (FuseReqT, LibC::Char*, FuseInoT, LibC::Char* -> Void)
    rename : (FuseReqT, FuseInoT, LibC::Char*, FuseInoT, LibC::Char* -> Void)
    link : (FuseReqT, FuseInoT, FuseInoT, LibC::Char* -> Void)
    open : (FuseReqT, FuseInoT, FuseFileInfo* -> Void)
    read : (FuseReqT, FuseInoT, LibC::SizeT, OffT, FuseFileInfo* -> Void)
    write : (FuseReqT, FuseInoT, LibC::Char*, LibC::SizeT, OffT, FuseFileInfo* -> Void)
    flush : (FuseReqT, FuseInoT, FuseFileInfo* -> Void)
    release : (FuseReqT, FuseInoT, FuseFileInfo* -> Void)
    fsync : (FuseReqT, FuseInoT, LibC::Int, FuseFileInfo* -> Void)
    opendir : (FuseReqT, FuseInoT, FuseFileInfo* -> Void)
    readdir : (FuseReqT, FuseInoT, LibC::SizeT, OffT, FuseFileInfo* -> Void)
    releasedir : (FuseReqT, FuseInoT, FuseFileInfo* -> Void)
    fsyncdir : (FuseReqT, FuseInoT, LibC::Int, FuseFileInfo* -> Void)
    statfs : (FuseReqT, FuseInoT -> Void)
    setxattr : (FuseReqT, FuseInoT, LibC::Char*, LibC::Char*, LibC::SizeT, LibC::Int, Uint32T -> Void)
    getxattr : (FuseReqT, FuseInoT, LibC::Char*, LibC::SizeT, Uint32T -> Void)
    listxattr : (FuseReqT, FuseInoT, LibC::SizeT -> Void)
    removexattr : (FuseReqT, FuseInoT, LibC::Char* -> Void)
    access : (FuseReqT, FuseInoT, LibC::Int -> Void)
    create : (FuseReqT, FuseInoT, LibC::Char*, ModeT, FuseFileInfo* -> Void)
    getlk : (FuseReqT, FuseInoT, FuseFileInfo*, Flock* -> Void)
    setlk : (FuseReqT, FuseInoT, FuseFileInfo*, Flock*, LibC::Int -> Void)
    bmap : (FuseReqT, FuseInoT, LibC::SizeT, Uint64T -> Void)
    ioctl : (FuseReqT, FuseInoT, LibC::Int, Void*, FuseFileInfo*, LibC::UInt, Void*, LibC::SizeT, LibC::SizeT -> Void)
    poll : (FuseReqT, FuseInoT, FuseFileInfo*, FusePollhandle* -> Void)
    write_buf : (FuseReqT, FuseInoT, FuseBufvec*, OffT, FuseFileInfo* -> Void)
    retrieve_reply : (FuseReqT, Void*, FuseInoT, OffT, FuseBufvec* -> Void)
    forget_multi : (FuseReqT, LibC::SizeT, FuseForgetData* -> Void)
    flock : (FuseReqT, FuseInoT, FuseFileInfo*, LibC::Int -> Void)
    fallocate : (FuseReqT, FuseInoT, LibC::Int, OffT, OffT, FuseFileInfo* -> Void)
    reserved00 : (FuseReqT, FuseInoT, Void*, Void*, Void*, Void*, Void*, Void* -> Void)
    reserved01 : (FuseReqT, FuseInoT, Void*, Void*, Void*, Void*, Void*, Void* -> Void)
    reserved02 : (FuseReqT, FuseInoT, Void*, Void*, Void*, Void*, Void*, Void* -> Void)
    reserved03 : (FuseReqT, FuseInoT, Void*, Void*, Void*, Void*, Void*, Void* -> Void)
    setvolname : (FuseReqT, LibC::Char* -> Void)
    exchange : (FuseReqT, FuseInoT, LibC::Char*, FuseInoT, LibC::Char*, LibC::ULong -> Void)
    getxtimes : (FuseReqT, FuseInoT, FuseFileInfo* -> Void)
    setattr_x : (FuseReqT, FuseInoT, SetattrX*, LibC::Int, FuseFileInfo* -> Void)
  end

  struct FuseLowlevelOpsCompat25
    init : (Void* -> Void)
    destroy : (Void* -> Void)
    lookup : (FuseReqT, FuseInoT, LibC::Char* -> Void)
    forget : (FuseReqT, FuseInoT, LibC::ULong -> Void)
    getattr : (FuseReqT, FuseInoT, FuseFileInfo* -> Void)
    setattr : (FuseReqT, FuseInoT, LibC::Stat*, LibC::Int, FuseFileInfo* -> Void)
    readlink : (FuseReqT, FuseInoT -> Void)
    mknod : (FuseReqT, FuseInoT, LibC::Char*, ModeT, DevT -> Void)
    mkdir : (FuseReqT, FuseInoT, LibC::Char*, ModeT -> Void)
    unlink : (FuseReqT, FuseInoT, LibC::Char* -> Void)
    rmdir : (FuseReqT, FuseInoT, LibC::Char* -> Void)
    symlink : (FuseReqT, LibC::Char*, FuseInoT, LibC::Char* -> Void)
    rename : (FuseReqT, FuseInoT, LibC::Char*, FuseInoT, LibC::Char* -> Void)
    link : (FuseReqT, FuseInoT, FuseInoT, LibC::Char* -> Void)
    open : (FuseReqT, FuseInoT, FuseFileInfo* -> Void)
    read : (FuseReqT, FuseInoT, LibC::SizeT, OffT, FuseFileInfo* -> Void)
    write : (FuseReqT, FuseInoT, LibC::Char*, LibC::SizeT, OffT, FuseFileInfo* -> Void)
    flush : (FuseReqT, FuseInoT, FuseFileInfo* -> Void)
    release : (FuseReqT, FuseInoT, FuseFileInfo* -> Void)
    fsync : (FuseReqT, FuseInoT, LibC::Int, FuseFileInfo* -> Void)
    opendir : (FuseReqT, FuseInoT, FuseFileInfo* -> Void)
    readdir : (FuseReqT, FuseInoT, LibC::SizeT, OffT, FuseFileInfo* -> Void)
    releasedir : (FuseReqT, FuseInoT, FuseFileInfo* -> Void)
    fsyncdir : (FuseReqT, FuseInoT, LibC::Int, FuseFileInfo* -> Void)
    statfs : (FuseReqT -> Void)
    setxattr : (FuseReqT, FuseInoT, LibC::Char*, LibC::Char*, LibC::SizeT, LibC::Int -> Void)
    getxattr : (FuseReqT, FuseInoT, LibC::Char*, LibC::SizeT -> Void)
    listxattr : (FuseReqT, FuseInoT, LibC::SizeT -> Void)
    removexattr : (FuseReqT, FuseInoT, LibC::Char* -> Void)
    access : (FuseReqT, FuseInoT, LibC::Int -> Void)
    create : (FuseReqT, FuseInoT, LibC::Char*, ModeT, FuseFileInfo* -> Void)
  end

  struct FuseModule
    name : LibC::Char*
    factory : (FuseArgs*, FuseFs** -> FuseFs*)
    next : FuseModule*
    so : Void*
    ctr : LibC::Int
  end

  struct Operations
    getattr : (LibC::Char*, LibC::Stat* -> LibC::Int)
    readlink : (LibC::Char*, LibC::Char*, LibC::SizeT -> LibC::Int)
    getdir : (LibC::Char*, FuseDirhT, FuseDirfilT -> LibC::Int)
    mknod : (LibC::Char*, ModeT, DevT -> LibC::Int)
    mkdir : (LibC::Char*, ModeT -> LibC::Int)
    unlink : (LibC::Char* -> LibC::Int)
    rmdir : (LibC::Char* -> LibC::Int)
    symlink : (LibC::Char*, LibC::Char* -> LibC::Int)
    rename : (LibC::Char*, LibC::Char* -> LibC::Int)
    link : (LibC::Char*, LibC::Char* -> LibC::Int)
    chmod : (LibC::Char*, ModeT -> LibC::Int)
    chown : (LibC::Char*, UidT, GidT -> LibC::Int)
    truncate : (LibC::Char*, OffT -> LibC::Int)
    utime : (LibC::Char*, Utimbuf* -> LibC::Int)
    open : (LibC::Char*, FuseFileInfo* -> LibC::Int)
    read : (LibC::Char*, LibC::Char*, LibC::SizeT, OffT, FuseFileInfo* -> LibC::Int)
    write : (LibC::Char*, LibC::Char*, LibC::SizeT, OffT, FuseFileInfo* -> LibC::Int)
    statfs : (LibC::Char*, Statvfs* -> LibC::Int)
    flush : (LibC::Char*, FuseFileInfo* -> LibC::Int)
    release : (LibC::Char*, FuseFileInfo* -> LibC::Int)
    fsync : (LibC::Char*, LibC::Int, FuseFileInfo* -> LibC::Int)
    setxattr : (LibC::Char*, LibC::Char*, LibC::Char*, LibC::SizeT, LibC::Int, Uint32T -> LibC::Int)
    getxattr : (LibC::Char*, LibC::Char*, LibC::Char*, LibC::SizeT, Uint32T -> LibC::Int)
    listxattr : (LibC::Char*, LibC::Char*, LibC::SizeT -> LibC::Int)
    removexattr : (LibC::Char*, LibC::Char* -> LibC::Int)
    opendir : (LibC::Char*, FuseFileInfo* -> LibC::Int)
    readdir : (LibC::Char*, Void*, FillDirT, OffT, FuseFileInfo* -> LibC::Int)
    releasedir : (LibC::Char*, FuseFileInfo* -> LibC::Int)
    fsyncdir : (LibC::Char*, LibC::Int, FuseFileInfo* -> LibC::Int)
    init : (FuseConnInfo* -> Void*)
    destroy : (Void* -> Void)
    access : (LibC::Char*, LibC::Int -> LibC::Int)
    create : (LibC::Char*, ModeT, FuseFileInfo* -> LibC::Int)
    ftruncate : (LibC::Char*, OffT, FuseFileInfo* -> LibC::Int)
    fgetattr : (LibC::Char*, LibC::Stat*, FuseFileInfo* -> LibC::Int)
    lock : (LibC::Char*, FuseFileInfo*, LibC::Int, Flock* -> LibC::Int)
    utimens : (LibC::Char*, Timespec[2] -> LibC::Int)
    bmap : (LibC::Char*, LibC::SizeT, Uint64T* -> LibC::Int)
    flag_nullpath_ok : LibC::UInt
    flag_nopath : LibC::UInt
    flag_utime_omit_ok : LibC::UInt
    flag_reserved : LibC::UInt
    ioctl : (LibC::Char*, LibC::Int, Void*, FuseFileInfo*, LibC::UInt, Void* -> LibC::Int)
    poll : (LibC::Char*, FuseFileInfo*, FusePollhandle*, LibC::UInt* -> LibC::Int)
    write_buf : (LibC::Char*, FuseBufvec*, OffT, FuseFileInfo* -> LibC::Int)
    read_buf : (LibC::Char*, FuseBufvec**, LibC::SizeT, OffT, FuseFileInfo* -> LibC::Int)
    flock : (LibC::Char*, FuseFileInfo*, LibC::Int -> LibC::Int)
    fallocate : (LibC::Char*, LibC::Int, OffT, OffT, FuseFileInfo* -> LibC::Int)
    reserved00 : (Void*, Void*, Void*, Void*, Void*, Void*, Void*, Void* -> LibC::Int)
    reserved01 : (Void*, Void*, Void*, Void*, Void*, Void*, Void*, Void* -> LibC::Int)
    reserved02 : (Void*, Void*, Void*, Void*, Void*, Void*, Void*, Void* -> LibC::Int)
    statfs_x : (LibC::Char*, Statfs* -> LibC::Int)
    setvolname : (LibC::Char* -> LibC::Int)
    exchange : (LibC::Char*, LibC::Char*, LibC::ULong -> LibC::Int)
    getxtimes : (LibC::Char*, Timespec*, Timespec* -> LibC::Int)
    setbkuptime : (LibC::Char*, Timespec* -> LibC::Int)
    setchgtime : (LibC::Char*, Timespec* -> LibC::Int)
    setcrtime : (LibC::Char*, Timespec* -> LibC::Int)
    chflags : (LibC::Char*, Uint32T -> LibC::Int)
    setattr_x : (LibC::Char*, SetattrX* -> LibC::Int)
    fsetattr_x : (LibC::Char*, SetattrX*, FuseFileInfo* -> LibC::Int)
  end

  struct OperationsCompat25
    getattr : (LibC::Char*, LibC::Stat* -> LibC::Int)
    readlink : (LibC::Char*, LibC::Char*, LibC::SizeT -> LibC::Int)
    getdir : (LibC::Char*, FuseDirhT, FuseDirfilT -> LibC::Int)
    mknod : (LibC::Char*, ModeT, DevT -> LibC::Int)
    mkdir : (LibC::Char*, ModeT -> LibC::Int)
    unlink : (LibC::Char* -> LibC::Int)
    rmdir : (LibC::Char* -> LibC::Int)
    symlink : (LibC::Char*, LibC::Char* -> LibC::Int)
    rename : (LibC::Char*, LibC::Char* -> LibC::Int)
    link : (LibC::Char*, LibC::Char* -> LibC::Int)
    chmod : (LibC::Char*, ModeT -> LibC::Int)
    chown : (LibC::Char*, UidT, GidT -> LibC::Int)
    truncate : (LibC::Char*, OffT -> LibC::Int)
    utime : (LibC::Char*, Utimbuf* -> LibC::Int)
    open : (LibC::Char*, FuseFileInfo* -> LibC::Int)
    read : (LibC::Char*, LibC::Char*, LibC::SizeT, OffT, FuseFileInfo* -> LibC::Int)
    write : (LibC::Char*, LibC::Char*, LibC::SizeT, OffT, FuseFileInfo* -> LibC::Int)
    statfs : (LibC::Char*, Statvfs* -> LibC::Int)
    flush : (LibC::Char*, FuseFileInfo* -> LibC::Int)
    release : (LibC::Char*, FuseFileInfo* -> LibC::Int)
    fsync : (LibC::Char*, LibC::Int, FuseFileInfo* -> LibC::Int)
    setxattr : (LibC::Char*, LibC::Char*, LibC::Char*, LibC::SizeT, LibC::Int -> LibC::Int)
    getxattr : (LibC::Char*, LibC::Char*, LibC::Char*, LibC::SizeT -> LibC::Int)
    listxattr : (LibC::Char*, LibC::Char*, LibC::SizeT -> LibC::Int)
    removexattr : (LibC::Char*, LibC::Char* -> LibC::Int)
    opendir : (LibC::Char*, FuseFileInfo* -> LibC::Int)
    readdir : (LibC::Char*, Void*, FillDirT, OffT, FuseFileInfo* -> LibC::Int)
    releasedir : (LibC::Char*, FuseFileInfo* -> LibC::Int)
    fsyncdir : (LibC::Char*, LibC::Int, FuseFileInfo* -> LibC::Int)
    init : (-> Void*)
    destroy : (Void* -> Void)
    access : (LibC::Char*, LibC::Int -> LibC::Int)
    create : (LibC::Char*, ModeT, FuseFileInfo* -> LibC::Int)
    ftruncate : (LibC::Char*, OffT, FuseFileInfo* -> LibC::Int)
    fgetattr : (LibC::Char*, LibC::Stat*, FuseFileInfo* -> LibC::Int)
  end

  struct FuseOpt
    templ : LibC::Char*
    offset : LibC::ULong
    value : LibC::Int
  end

  struct SessionOps
    process : (Void*, LibC::Char*, LibC::SizeT, FuseChan* -> Void)
    exit : (Void*, LibC::Int -> Void)
    exited : (Void* -> LibC::Int)
    destroy : (Void* -> Void)
  end

  struct Iovec
    iov_base : Void*
    iov_len : LibC::SizeT
  end

  struct SetattrX
    valid : Int32T
    mode : ModeT
    uid : UidT
    gid : GidT
    size : OffT
    acctime : Timespec
    modtime : Timespec
    crtime : Timespec
    chgtime : Timespec
    bkuptime : Timespec
    flags : Uint32T
  end

  struct Stat
    st_dev : DevT
    st_mode : ModeT
    st_nlink : NlinkT
    st_ino : X__DarwinIno64T
    st_uid : UidT
    st_gid : GidT
    st_rdev : DevT
    st_atimespec : Timespec
    st_mtimespec : Timespec
    st_ctimespec : Timespec
    st_birthtimespec : Timespec
    st_size : OffT
    st_blocks : BlkcntT
    st_blksize : BlksizeT
    st_flags : X__Uint32T
    st_gen : X__Uint32T
    st_lspare : X__Int32T
    st_qspare : X__Int64T[2]
  end

  struct Statfs
    f_bsize : Uint32T
    f_iosize : Int32T
    f_blocks : Uint64T
    f_bfree : Uint64T
    f_bavail : Uint64T
    f_files : Uint64T
    f_ffree : Uint64T
    f_fsid : FsidT
    f_owner : UidT
    f_type : Uint32T
    f_flags : Uint32T
    f_fssubtype : Uint32T
    f_fstypename : LibC::Char[16]
    f_mntonname : LibC::Char[1024]
    f_mntfromname : LibC::Char[1024]
    f_reserved : Uint32T[8]
  end

  struct Statvfs
    f_bsize : LibC::ULong
    f_frsize : LibC::ULong
    f_blocks : FsblkcntT
    f_bfree : FsblkcntT
    f_bavail : FsblkcntT
    f_files : FsfilcntT
    f_ffree : FsfilcntT
    f_favail : FsfilcntT
    f_fsid : LibC::ULong
    f_flag : LibC::ULong
    f_namemax : LibC::ULong
  end

  struct Timespec
    tv_sec : X__DarwinTimeT
    tv_nsec : LibC::Long
  end

  struct Utimbuf
    actime : TimeT
    modtime : TimeT
  end

  type FsidT = Fsid
  type FuseDirhT = Void*
  type FuseReqT = Void*
end; end
