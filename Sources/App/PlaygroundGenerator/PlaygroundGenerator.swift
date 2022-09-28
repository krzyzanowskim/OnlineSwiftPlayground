// Copyright Marcin Krzyżanowski <marcin@krzyzanowskim.com>

import Xgen
import TSCBasic
import Foundation
import ZIPFoundation

func generataPlayground(code: String) throws -> AbsolutePath {
    let fileManager = FileManager()

    return try withTemporaryDirectory(prefix: ProcessInfo.processInfo.globallyUniqueString) { temporaryDirectory in
        let playgroundPath = temporaryDirectory.appending(component: "Playground.playground")
        let archivePath = temporaryDirectory.appending(component: "Playground.zip")

        let playground = Playground(path: playgroundPath.pathString, platform: .macOS, code: code)
        try playground.generate()

        try fileManager.zipItem(at: playgroundPath.asURL, to: archivePath.asURL)

        return archivePath
    }
}
