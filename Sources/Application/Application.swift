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
    static let defaultContext:[String: Any] = [:]

    public init() throws {
        router = Router(mergeParameters: true)

        server = Server(router: router)

        // UUID secret for the session. Session is not persistent
        router.all(middleware: Session(secret: UUID().uuidString))
    }

    func postInit() throws {
        let authEnabled = try setupCredentials(router: router)
        if !authEnabled {
            // No-auth flow provides a "fake" url's. Not Sign-in is performed.
            router.get("/login/github", handler: { (request, response, next) in
                try response.redirect("/playground")
                next()
            })
            router.get("/playground") { request, response, next in
                try response.render("playground.html", context: App.defaultContext).end()
            }
            router.get("/") { request, response, next in
                try response.render("index.html", context: App.defaultContext).end()
            }
        } else {
            router.get("/") { request, response, next in
                if let userProfile = request.userProfile {
                    var context = App.defaultContext
                    context["userProfile"] = userProfile
                    try response.render("playground.html", context: context).end()
                } else {
                    try response.render("index.html", context: App.defaultContext).end()
                }
            }
        }

        router.add(templateEngine: StencilTemplateEngine(), forFileExtensions: ["html"])

        // Common endpoints
        router.all("/static", middleware: StaticFileServer(path: "./static", options: StaticFileServer.Options(serveIndexForDirectory: false)))

        router.get("/logout") { request, response, next in
            try response.render("logout.html", context: App.defaultContext).end()
        }

        // WebSockets
        WebSocket.register(service: TerminalService(), onPath: "terminal")

        // Defaults
        router.all { (request, response, next) in
            if response.statusCode == .unknown || response.statusCode == .notFound {
                try response.redirect("/static/404.html").end()
                return
            }
            next()
        }
    }

    public func run() throws {
        try postInit()
        Server(router: router).run()
    }
}
