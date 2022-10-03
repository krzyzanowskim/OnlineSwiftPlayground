//
//  File.swift
//
//
//  Created by Josef Dolezal on 26.09.2022.
//

import Vapor

struct APIController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let api = routes.grouped("api")

        // TODO: Move shell invocation to service
        api.get("versions") { (req: Request) async throws -> Response in
            let task = Process()
            let pipe = Pipe()

            task.standardOutput = pipe
            task.standardError = pipe
            task.arguments = ["-c", "swiftenv versions --bare"]
            task.launchPath = "/bin/sh"
            task.standardInput = nil
            task.launch()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: data, encoding: .utf8) else {
                return Response(status: .internalServerError)
            }

            return try await output.split(separator: "\n").map { String($0) }.encodeResponse(for: req)
        }

        api.webSocket("terminal") { req, websocket in
            req.terminal.connected(on: websocket)
        }
    }
}
