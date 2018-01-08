// Copyright Marcin Krzyżanowski <marcin@krzyzanowskim.com>

import Foundation

enum AnnotationType: String, Codable {
    case error = "error"
    case warning = "warning"
    case notice = "notice"
}

struct AnnotationLocation: Codable {
    let row: Int
    let column: Int
}

struct Annotation: Codable {
    let type: AnnotationType
    let location: AnnotationLocation
    let description: String
}
