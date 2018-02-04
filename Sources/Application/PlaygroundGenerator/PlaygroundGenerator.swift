// Copyright Marcin Krzyżanowski <marcin@krzyzanowskim.com>

import Xgen
import Basic
import Foundation
import ZIPFoundation

func generataPlayground(code: String) throws -> AbsolutePath {
    let fileManager = FileManager()

    let temporaryDirectory = try TemporaryDirectory(prefix: ProcessInfo.processInfo.globallyUniqueString)
    let playgroundPath = temporaryDirectory.path.appending(component: "Playground.playground")
    let archivePath = temporaryDirectory.path.appending(component: "Playground.zip")

    let playground = Playground(path: playgroundPath.asString, platform: .macOS, code: code)
    try playground.generate()

    try fileManager.zipItem(at: playgroundPath.asURL, to: archivePath.asURL)
    return archivePath
}
