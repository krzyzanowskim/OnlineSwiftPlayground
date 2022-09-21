// Copyright Marcin Krzyżanowski <marcin@krzyzanowskim.com>

import Dispatch
import Foundation
import TSCBasic
import TSCUtility

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public enum SwiftToolchain: String, RawRepresentable, Codable {
    // case swift5_0 = "5.0-RELEASE"
    case swift5_7 = "5.7-RELEASE"

    // Path to toolchain, relative to current process PWD
    var path: RelativePath {
        RelativePath("Toolchains").appending(components: "swift-\(self.rawValue).xctoolchain", "usr", "bin")
    }

    var swift_version: String {
        switch self {
        // case .swift5_0:
        //   return "5"
        case .swift5_7:
          return "5"
        }
    }
}


public class BuildToolchain {
    public enum Error: Swift.Error {
        case failed(String)
    }

    private let processSet = ProcessSet()

    public init() { }

    public func build(code: String, toolchain: SwiftToolchain, root: AbsolutePath) throws -> Result<AbsolutePath, Error> {
        let fileSystem = TSCBasic.localFileSystem
        let projectDirectoryPath = root

        return try withTemporaryDirectory(prefix: ProcessInfo.processInfo.globallyUniqueString) { temporaryBuildDirectory in
            let mainFilePath = temporaryBuildDirectory.appending(RelativePath("main.swift"))
            let binaryFilePath = temporaryBuildDirectory.appending(component: "main")
            let frameworksDirectory = projectDirectoryPath.appending(component: "Frameworks")

            try fileSystem.writeFileContents(mainFilePath, bytes: ByteString(encodingAsUTF8: injectCodeText + code))

            let target: String
            #if os(macOS)
                target = "x86_64-apple-macosx10.11"
            #endif
            #if os(Linux)
                target = "x86_64-unknown-linux-gnu"
            #endif

            var cmd = [String]()
            cmd += ["\(toolchain.path.pathString)/swiftc"]
            cmd += ["-swift-version", toolchain.swift_version]
            #if DEBUG
            cmd += ["-v"]
            #endif
            cmd += ["-gnone"]
            cmd += ["-suppress-warnings"]
            cmd += ["-module-name", "SwiftPlayground"]
            // Darwin is implicitly imported with Foundation, but Glibc is not. Glibc is not on Linux.
            #if os(Linux)
                cmd += ["-module-link-name","Glibc"]
            #endif
            #if DEBUG
                cmd += ["-I", projectDirectoryPath.appending(components: "OnlinePlayground", "OnlinePlayground-\(toolchain.rawValue)", ".build", "debug").pathString]
                cmd += ["-L", projectDirectoryPath.appending(components: "OnlinePlayground", "OnlinePlayground-\(toolchain.rawValue)", ".build", "debug").pathString]
            #else
                cmd += ["-I", projectDirectoryPath.appending(components: "OnlinePlayground", "OnlinePlayground-\(toolchain.rawValue)", ".build", "release").pathString]
                cmd += ["-L", projectDirectoryPath.appending(components: "OnlinePlayground", "OnlinePlayground-\(toolchain.rawValue)", ".build", "release").pathString]
            #endif
            cmd += ["-lOnlinePlayground"]
//            cmd += ["-target", target]
            #if os(macOS)
                cmd += ["-F", frameworksDirectory.pathString]
                cmd += ["-Xlinker", "-rpath", "-Xlinker", frameworksDirectory.pathString]
            #endif

            // Optimization or not
            #if os(macOS)
                cmd += ["-sanitize=address"]
            #else
                cmd += ["-O"]
            #endif
            // cmd += ["-enforce-exclusivity=checked"] // needs -Onone
            // Enable JSON-based output at some point.
            // cmd += ["-parseable-output"]
            if let sdkRoot = sdkRoot() {
                cmd += ["-sdk", sdkRoot.pathString]
            }
            cmd += ["-o", binaryFilePath.pathString]
            cmd += [mainFilePath.pathString]

            print(cmd.joined(separator: " "))

            let process = TSCBasic.Process(arguments: cmd, outputRedirection: .collect)
            try processSet.add(process)
            try process.launch()
            let result = try process.waitUntilExit()

            switch result.exitStatus {
            case .terminated(let exitCode) where exitCode == 0:
                return Result.success(binaryFilePath)
            case .signalled(let signal):
                return Result.failure(Error.failed("Terminated by signal \(signal)"))
            default:
                return Result.failure(Error.failed(try (result.utf8Output() + result.utf8stderrOutput()).spm_chuzzle() ?? "Terminated."))
            }
        }
    }

    public func run(binaryPath: AbsolutePath) throws -> Result<String, Error> {
        var cmd = [String]()
        #if os(macOS)
            // Use sandbox-exec on macOS. This provides some safety against arbitrary code execution.
            cmd += ["sandbox-exec", "-p", sandboxProfile()]
        #endif
        cmd += [binaryPath.pathString]

        let process = TSCBasic.Process(arguments: cmd, environment: [:], outputRedirection: .collect)
        try processSet.add(process)
        try process.launch()
        let result = try process.waitUntilExit()

        // Remove container directory. Cleanup after run.
        try FileManager.default.removeItem(atPath: binaryPath.parentDirectory.pathString)

        switch result.exitStatus {
        case .terminated(let exitCode) where exitCode == 0:
            return Result.success(try result.utf8Output().spm_chuzzle() ?? "Done.")
        case .signalled(let signal):
            return Result.failure(Error.failed("Terminated by signal \(signal)"))
        default:
            return Result.failure(Error.failed(try (result.utf8Output() + result.utf8stderrOutput()).spm_chuzzle() ?? "Terminated."))
        }
    }

    private var _sdkRoot: AbsolutePath?
    private func sdkRoot() -> AbsolutePath? {
        if let sdkRoot = _sdkRoot {
            return sdkRoot
        }

        // Find SDKROOT on macOS using xcrun.
        #if os(macOS)
            let foundPath = try? Process.checkNonZeroExit(
                args: "xcrun", "--sdk", "macosx", "--show-sdk-path")
            guard let sdkRoot = foundPath?.spm_chomp(), !sdkRoot.isEmpty else {
                return nil
            }
            _sdkRoot = AbsolutePath(sdkRoot)
        #endif

        return _sdkRoot
    }
}

private func sandboxProfile() -> String {
    var output = """
    (version 1)
    (deny default)
    (import \"system.sb\")
    (allow file-read*)
    (allow process*)
    (allow sysctl*)
    (allow file-write*
    """
    for directory in Platform.darwinCacheDirectories() {
        output += "    (regex #\"^\(directory.pathString)/org\\.llvm\\.clang.*\")"
        output += "    (regex #\"^\(directory.pathString)/xcrun_db.*\")"
    }
    output += ")\n"
    return output
}

let injectCodeText = """
import OnlinePlayground
OnlinePlayground.setup

"""
