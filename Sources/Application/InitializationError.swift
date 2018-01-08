// Copyright Marcin Krzyżanowski <marcin@krzyzanowskim.com>

import Foundation

public struct InitializationError: Swift.Error {
	let message: String
	init(_ msg: String) {
		message = msg
	}
}

extension InitializationError: LocalizedError {
	public var errorDescription: String? {
		return message
	}
}
