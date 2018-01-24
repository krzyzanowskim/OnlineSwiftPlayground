// Copyright Marcin Krzyżanowski <marcin@krzyzanowskim.com>

import Basic
import Utility
import FileKit
import LoggerAPI
import Foundation
import Dispatch

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif


class BuildToolchain {
    enum Error: Swift.Error {
        case failed(String)
    }

    private let processSet = ProcessSet()

    func build(code: String) throws -> Result<AbsolutePath, Error> {
        let fileSystem = Basic.localFileSystem
        let projectDirectoryPath = AbsolutePath(FileKit.projectFolder)

        let temporaryBuildDirectory = try TemporaryDirectory(prefix: ProcessInfo.processInfo.globallyUniqueString)
        let mainFilePath = temporaryBuildDirectory.path.appending(RelativePath("main.swift"))
        let binaryFilePath = temporaryBuildDirectory.path.appending(component: "main")
        let frameworksDirectory = projectDirectoryPath.appending(component: "Frameworks")

        try fileSystem.writeFileContents(mainFilePath, bytes: ByteString(encodingAsUTF8: injectCodeText + code))

        var cmd = [String]()
        cmd += ["swift"]
        cmd += ["--driver-mode=swiftc"]
        cmd += ["-v"]
        cmd += ["-gnone"]
        cmd += ["-suppress-warnings"]
        cmd += ["-module-name","SwiftPlayground"]
        // cmd += ["-O"]
        cmd += ["-I",projectDirectoryPath.appending(components: ".build","release").asString]
        cmd += ["-L",projectDirectoryPath.appending(components: ".build","release").asString]
        cmd += ["-lOnlinePlayground"]
        #if os(macOS)
            cmd += ["-target", "x86_64-apple-macosx10.10"]
            cmd += ["-F",frameworksDirectory.asString]
            cmd += ["-Xlinker","-rpath","-Xlinker",frameworksDirectory.asString]
            cmd += ["-sanitize=address"]
        #endif
        #if os(Linux)
            cmd += ["-target", "x86_64-unknown-linux-gnu"]
        #endif
        // Enable JSON-based output at some point.
        // cmd += ["-parseable-output"]
        cmd += ["-enforce-exclusivity=checked"]
        cmd += ["-swift-version","4"]
        if let sdkRoot = sdkRoot() {
            cmd += ["-sdk", sdkRoot.asString]
        }
        cmd += ["-o",binaryFilePath.asString]
        cmd += [mainFilePath.asString]

        let process = Basic.Process(arguments: cmd, redirectOutput: true, verbose: false)
        try processSet.add(process)
        try process.launch()
        let result = try process.waitUntilExit()

        switch result.exitStatus {
        case .terminated(let exitCode) where exitCode == 0:
            return Result.success(binaryFilePath)
        case .signalled(let signal):
            return Result.failure(Error.failed("Terminated by signal \(signal)"))
        default:
            return Result.failure(Error.failed(try (result.utf8Output() + result.utf8stderrOutput()).chuzzle() ?? "Terminated."))
        }
    }

    func run(binaryPath: AbsolutePath) throws -> Result<String, Error> {
        var cmd = [String]()
        #if os(macOS)
            // Use sandbox-exec on macOS. This provides some safety against arbitrary code execution.
            cmd += ["sandbox-exec", "-p", sandboxProfile()]
        #endif
        cmd += [binaryPath.asString]

        let process = Basic.Process(arguments: cmd, environment: [:], redirectOutput: true, verbose: false)
        try processSet.add(process)
        try process.launch()
        let result = try process.waitUntilExit()

        // Remove container directory. Cleanup after run.
        try FileManager.default.removeItem(atPath: binaryPath.parentDirectory.asString)

        switch result.exitStatus {
        case .terminated(let exitCode) where exitCode == 0:
            return Result.success(try result.utf8Output().chuzzle() ?? "Done.")
        case .signalled(let signal):
            return Result.failure(Error.failed("Terminated by signal \(signal)"))
        default:
            return Result.failure(Error.failed(try (result.utf8Output() + result.utf8stderrOutput()).chuzzle() ?? "Terminated."))
        }
    }

    private var _sdkRoot: AbsolutePath? = nil
    private func sdkRoot() -> AbsolutePath? {
        if let sdkRoot = _sdkRoot {
            return sdkRoot
        }

        // Find SDKROOT on macOS using xcrun.
        #if os(macOS)
            let foundPath = try? Process.checkNonZeroExit(
                args: "xcrun", "--sdk", "macosx", "--show-sdk-path")
            guard let sdkRoot = foundPath?.chomp(), !sdkRoot.isEmpty else {
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
        output += "    (regex #\"^\(directory.asString)/org\\.llvm\\.clang.*\")"
        output += "    (regex #\"^\(directory.asString)/xcrun_db.*\")"
    }
    output += ")\n"
    return output
}

let injectCodeText = """
    import OnlinePlayground;
    OnlinePlayground.setup;

    """

