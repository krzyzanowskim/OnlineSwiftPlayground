// Copyright Marcin Krzyżanowski <marcin@krzyzanowskim.com>

import Foundation
import Kitura
import KituraWebSocket
import LoggerAPI
import Configuration
import KituraSession
import Credentials
import KituraStencil
import FileKit
import Basic

public let projectPath = ConfigurationManager.BasePath.project.path

enum Error: Swift.Error {
    case missingConfig
}

public class App {
    let router: Router
    let server: Server
    let credentials: Credentials?
    static let defaultContext:[String: Any] = [:]

    public init() throws {
        router = Router()

        server = Server(router: router)

        // UUID secret for the session. Session is not persistent
        router.all(middleware: Session(secret: UUID().uuidString))

        credentials = try setupCredentials(router: router)
    }

    func postInit() throws {
        router.add(templateEngine: StencilTemplateEngine(), forFileExtensions: ["html"])

        // Common endpoints
        router.all("/static", middleware: StaticFileServer(path: "./static", options: StaticFileServer.Options(serveIndexForDirectory: false)))

        router.get("/signin") { request, response, next in
            response.headers["Content-Type"] = "text/html"
            try response.render("signin.stencil.html", context: App.defaultContext).end()
        }

        router.get("/logout") { request, response, next in
            self.credentials?.logOut(request: request)
            try response.render("logout.stencil.html", context: App.defaultContext).end()
        }

        router.get("/") { request, response, next in
            try response.render("playground.stencil.html", context: App.defaultContext)
            next()
        }

        router.get("/embed") { request, response, next in
            var context = App.defaultContext
            context["embed"] = "1"
            try response.render("playground.stencil.html", context: context)
            next()
        }

        // WebSockets
        WebSocket.register(service: TerminalService(), onPath: "terminal")
    }

    public func run() throws {
        try postInit()
        Server.init(router: router).run()
    }
}
