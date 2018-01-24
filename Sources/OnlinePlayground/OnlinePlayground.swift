import Foundation
@_exported import CryptoSwift

#if os(macOS)
    import Darwin
#else
    import Glibc
#endif

public final class OnlinePlayground {
    public static let setup:() = {
        OnlinePlayground().setLimits()
    }()

    // Limit once set for the process, can't be changed later
    func setLimits() {
        var rcpu = rlimit(rlim_cur: 7, rlim_max: 15) // 7s
        var rfsize = rlimit(rlim_cur: 1048576, rlim_max: 1048576) // 1 MB
        var rcore = rlimit(rlim_cur: 0, rlim_max: 0)
        var rnproc = rlimit(rlim_cur: 1, rlim_max: 1)
        var rnofile = rlimit(rlim_cur: 1, rlim_max: 1)

        #if os(macOS)
            setrlimit(RLIMIT_CPU, &rcpu)
            setrlimit(RLIMIT_CORE, &rcore)
            setrlimit(RLIMIT_FSIZE, &rfsize)
            setrlimit(RLIMIT_NOFILE, &rnofile)
            setrlimit(RLIMIT_NPROC, &rnproc)

            setiopolicy_np(IOPOL_TYPE_DISK, IOPOL_SCOPE_PROCESS, IOPOL_UTILITY)
        #else
            setrlimit(__rlimit_resource_t(0), &rcpu) // RLIMIT_CPU = 0
            setrlimit(__rlimit_resource_t(1), &rfsize) // RLIMIT_FSIZE = 1
            setrlimit(__rlimit_resource_t(4), &rcore) // RLIMIT_CORE = 4
            setrlimit(__rlimit_resource_t(6), &rnproc) // __RLIMIT_NPROC = 6
            setrlimit(__rlimit_resource_t(7), &rnofile) // RLIMIT_NOFILE = 7

            // var rnice = rlimit(rlim_cur: 1, rlim_max: 1)
            // setrlimit(__rlimit_resource_t(13), &rnice) // __RLIMIT_NICE = 13
        #endif
    }
}
