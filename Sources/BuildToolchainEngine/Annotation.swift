// Copyright Marcin Krzyżanowski <marcin@krzyzanowskim.com>

import Foundation

public enum AnnotationType: String, Codable {
    case error = "error"
    case warning = "warning"
    case notice = "notice"
}

public struct AnnotationLocation: Codable {
    let row: Int
    let column: Int
}

public struct Annotation: Codable {
    let type: AnnotationType
    let location: AnnotationLocation
    let description: String
}
