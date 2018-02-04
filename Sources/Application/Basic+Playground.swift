// Copyright Marcin Krzyżanowski <marcin@krzyzanowskim.com>

import Foundation
import Basic

extension AbsolutePath {
    var asURL: URL {
        get {
            return URL.init(fileURLWithPath: self.asString)
        }
    }
}
