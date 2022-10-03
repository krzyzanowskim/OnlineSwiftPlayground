import Vapor

struct FrontEndController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: index)
        routes.get("privacy-polic", use: privacyPolicy)
        routes.get("letsplay", use: letsPlay)
        routes.get("logout", use: logout)
        routes.get("download", use: download)
    }

    func index(req: Request) async throws -> View {
        if req.session.data["playground"] == "true" {
            return try await req.view.render("playground")
        } else {
            return try await req.view.render("index")
        }
    }

    func privacyPolicy(req: Request) async throws -> View {
        try await req.view.render("privacy-policy")
    }

    func letsPlay(req: Request) async throws -> Response {
        req.session.data["playground"] = "true"
        return req.redirect(to: "/")
    }

    func logout(req: Request) async throws -> View {
        req.session.destroy()
        return try await req.view.render("logout")
    }

    func download(req: Request) async throws -> Response {
        let content = try req.content.decode(DownloadRequest.self)
        let playgroundPath = try generataPlayground(code: content.code)
        return req.fileio.streamFile(at: playgroundPath.pathString)
    }
}
