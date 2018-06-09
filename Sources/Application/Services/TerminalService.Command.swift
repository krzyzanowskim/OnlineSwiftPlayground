// Copyright Marcin Krzyżanowski <marcin@krzyzanowskim.com>

import Foundation

extension TerminalService {
    enum Command {
        enum Error: Swift.Error {
            case invalid
        }

        case run(String, SwiftToolchain)
        case output(String, [Annotation])
    }
}

extension TerminalService.Command: Codable {
    enum CodingKeys: String, CodingKey {
        case run
        case output
    }

    enum RunCodingKeys: String, CodingKey {
        case value
        case toolchain
    }

    enum OutputCodingKeys: String, CodingKey {
        case value
        case annotations
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        guard let valueDict = try values.decodeIfPresent([String: String].self, forKey: .run),
            let sourceCode = valueDict["value"],
            let toolchainString = valueDict["toolchain"],
            let toolchain = SwiftToolchain(rawValue: toolchainString)
        else {
            throw Error.invalid
        }

        self = TerminalService.Command.run(sourceCode, toolchain)
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .output(let codeText, let annotations):
            var container = encoder.container(keyedBy: CodingKeys.self)
            var nested = container.nestedContainer(keyedBy: OutputCodingKeys.self, forKey: .output)
            try nested.encode(annotations, forKey: .annotations)
            try nested.encode(codeText, forKey: .value)
        case .run(let codeText, let toolchain):
            var container = encoder.container(keyedBy: CodingKeys.self)
            var nested = container.nestedContainer(keyedBy: RunCodingKeys.self, forKey: .run)
            try nested.encode(toolchain, forKey: .toolchain)
            try nested.encode(codeText, forKey: .value)
        }
    }
}
