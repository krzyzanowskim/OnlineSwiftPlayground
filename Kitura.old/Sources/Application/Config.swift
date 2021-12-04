// Copyright Marcin Krzyżanowski <marcin@krzyzanowskim.com>

// abstract CloudEnvironment due to https://github.com/IBM-Swift/CloudEnvironment/issues/47
import Foundation
import Configuration
import CloudEnvironment

class Config {
    let cloudEnv = CloudEnv()

    static let shared = Config()
    
    subscript(key: String) -> [String: Any]? {
        return cloudEnv.getDictionary(name: key)
    }
}
