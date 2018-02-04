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
        router.all("/*", middleware: BodyParser())

        router.get("/") { request, response, next in
            if let session = request.session, session["playground"] as? Bool == true {
                try response.render("playground.html", context: App.defaultContext).end()
            } else {
                try response.render("index.html", context: App.defaultContext).end()
            }
        }

        router.all("/letsplay") { request, response, next in
            request.session?["playground"] = true
            try response.redirect("/")
        }

        router.add(templateEngine: StencilTemplateEngine(), forFileExtensions: ["html"])

        // Common endpoints
        router.all("/static", middleware: StaticFileServer(path: "./static", options: StaticFileServer.Options(serveIndexForDirectory: false)))

        router.get("/logout") { request, response, next in
            request.session?.destroy { (error) in
                if let error = error {
                    Log.error(error.localizedDescription)
                }
            }
            try response.render("logout.html", context: App.defaultContext).end()
        }

        router.post("/download") { request, response, next in
            guard let code = request.body?.asURLEncoded?["code"], code.count > 0 else {
                next()
                return
            }

            let playgroundPath = try generataPlayground(code: code)
            try response.send(download: playgroundPath.asString)
            try response.end()
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
