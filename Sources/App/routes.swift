import Vapor

extension Application {
    func routes() throws {
        get { req async throws -> View in
            if req.session.data["playground"] == "true" {
                return try await req.view.render("playground")
            } else {
                return try await req.view.render("index")
            }
        }

        get("privacy-policy") { req async throws -> View in
            return try await req.view.render("privacy-policy")
        }

        // router.all
        get("letsplay") { req -> Response in
            req.session.data["playground"] = "true"
            return req.redirect(to: "/")
        }

        get("logout") { req async throws -> View in
            req.session.destroy()
            return try await req.view.render("logout")
        }

        post("download") { req async throws -> Response in
            let content = try req.content.decode(DownloadRequest.self)
            let playgroundPath = try generataPlayground(code: content.code)
            return req.fileio.streamFile(at: playgroundPath.pathString)
        }

        webSocket("terminal") { req, ws in
            req.terminal.connected(on: ws)
        }
    }
}
