// Copyright Marcin Krzyżanowski <marcin@krzyzanowskim.com>

import Foundation

extension TerminalService {
    enum Command: CustomStringConvertible, RawRepresentable, Codable {

        enum Error: Swift.Error {
            case invalid
        }

        case run(String)
        case output(String, [Annotation])

        enum CodingKeys: String, CodingKey {
            case run = "run"
            case output = "output"

            case value = "value"
            case annotations = "annotations"
        }

        typealias RawValue = [String: [String: Any]]

        init?(rawValue: RawValue) {
            guard !rawValue.isEmpty else {
                return nil
            }

            if let valueDict = rawValue[CodingKeys.run.rawValue], let value = valueDict[CodingKeys.value.rawValue] as? String {
                self = Command.run(value)
            }

            if let valueDict = rawValue[CodingKeys.output.rawValue], let value = valueDict[CodingKeys.value.rawValue] as? String {
                self = Command.output(value, valueDict[CodingKeys.annotations.rawValue] as? [Annotation] ?? [])
            }

            return nil
        }

        var rawValue: RawValue {
            switch self {
            case .run(let codeText):
                return [CodingKeys.run.rawValue: [CodingKeys.value.rawValue: codeText]]
            case .output(let output, _):
                return [CodingKeys.output.rawValue: [CodingKeys.value.rawValue: output]]
            }
        }

        var description: String {
            return rawValue.description
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            if let valueDict = try values.decodeIfPresent([String: String].self, forKey: CodingKeys.run), let value = valueDict["value"] {
                self = Command.run(value)
                return
            }

            throw Error.invalid
        }

        func encode(to encoder: Encoder) throws {
            switch self {
            case .output(let codeText, let annotations):
                var container = encoder.container(keyedBy: CodingKeys.self)
                var nested = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .output)
                try nested.encode(annotations, forKey: .annotations)
                try nested.encode(codeText, forKey: .value)
            default:
                throw Error.invalid
            }
        }
    }
}
