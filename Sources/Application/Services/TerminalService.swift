// Copyright Marcin Krzyżanowski <marcin@krzyzanowskim.com>

import Foundation
import KituraWebSocket
import Basic
import Utility
import Dispatch

struct Connection {
    let id: String
    let webSocket: WebSocketConnection

    init(webSocketConnection: WebSocketConnection) {
        id = webSocketConnection.id
        webSocket = webSocketConnection
    }

    func ping() {
        webSocket.ping()
    }

    func send(message: String) {
        webSocket.send(message: message)
    }

    func send(message: Data) {
        webSocket.send(message: message)
    }
}

class TerminalService: WebSocketService {
    let buildToolchain = BuildToolchain()

    enum Error: Swift.Error {
        case unknown
    }

    private var connections = [String: Connection]()
    private lazy var timer: DispatchSourceTimer = {
        let t = DispatchSource.makeTimerSource()
        t.schedule(deadline: DispatchTime.now() + 5, repeating: 30)
        t.setEventHandler(handler: DispatchWorkItem(block: { [weak self] in
            self?.connections.values.forEach({ (connection) in
                connection.ping()
            })
        }))
        return t
    }()

    init() {
        timer.resume()
    }

    public func connected(connection: WebSocketConnection) {
        connections[connection.id] = Connection(webSocketConnection: connection)
    }

    public func disconnected(connection: WebSocketConnection, reason: WebSocketCloseReasonCode) {
        connections.removeValue(forKey: connection.id)
    }

    public func received(message: Data, from: WebSocketConnection) {
        from.close(reason: .invalidDataType, description: "Terminal-Server only accepts text messages")
        connections.removeValue(forKey: from.id)
    }

    public func received(message: String, from: WebSocketConnection) {
        guard let data = message.data(using: .utf8), let command = try? JSONDecoder().decode(Command.self, from: data),
              let connection = connections[from.id]
        else {
            return
        }

        switch command {
        case .run(let codeText):
            if let result = run(codeText: codeText) {
                if let responseJSON = try? JSONEncoder().encode(Command.output(result.text, result.annotations ?? [])),
                   let responseString = String(data: responseJSON, encoding: .utf8)
                {
                    connection.send(message: responseString)
                }
            }
            break
        default:
            break;
        }

    }
}

private struct RunResult {
    let text: String
    let annotations: [Annotation]?
}

private extension TerminalService {
    private func run(codeText: String) -> RunResult? {
        do {
            let buildResult = try buildToolchain.build(code: codeText)
            let runResult = try buildToolchain.run(binaryPath: buildResult.dematerialize())
            return RunResult(text: try runResult.dematerialize(), annotations: nil)
        } catch BuildToolchain.Error.failed(let output) {
            let items = try? SwiftcOutputParser().parse(input: output)
            return RunResult(text: output, annotations: items)
        } catch {
            return RunResult(text: error.localizedDescription, annotations: nil)
        }
    }
}

