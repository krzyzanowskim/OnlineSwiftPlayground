// Copyright Marcin Krzyżanowski <marcin@krzyzanowskim.com>

import Basic
import Utility
import Foundation

/*
/var/folders/24/8k48jl6d249_n_qfxwsl6xvm0000gn/T/TemporaryFile.XRyEA4.swift:29:8: error: no such module 'CryptoSwift'
import CryptoSwift
       ^
 */

class SwiftcOutputParser {
    let adjustRow = -injectCodeText.components(separatedBy: .newlines).count

    func parse(input: String) throws -> [Annotation] {
        var items = [Annotation]()
        let results = try RegEx(pattern: ".*.swift:((\\d+?)\\:(\\d+?))\\: (error)\\: (.*)").matchGroups(in: input)
        for result in results {
            guard let row = Int(result[1]), let column = Int(result[2]) else { continue }
            items += [Annotation(type: .error, location: AnnotationLocation(row: row + adjustRow, column: column), description: result[4])]
        }
        return items
    }
}
