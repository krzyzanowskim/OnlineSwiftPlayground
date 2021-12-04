// Copyright Marcin Krzyżanowski <marcin@krzyzanowskim.com>

import Xgen
import Basic
import Foundation
import ZIPFoundation

func generataPlayground(code: String) throws -> String {
    let fileManager = FileManager()

    let temporaryDirPath = try TemporaryDirectory(prefix: ProcessInfo.processInfo.globallyUniqueString).path.pathString
    let playgroundPath = temporaryDirPath + "/Playground.playground"
    let archivePath = temporaryDirPath + "/Playground.zip"

    let playground = Playground(path: playgroundPath, platform: .macOS, code: code)
    try playground.generate()

    try fileManager.zipItem(at: URL(fileURLWithPath: playgroundPath, isDirectory: true), to: URL(fileURLWithPath: archivePath, isDirectory: false))
    return archivePath
}
