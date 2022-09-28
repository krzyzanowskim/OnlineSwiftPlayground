import Vapor
import Leaf

public extension Application {
    func configure() throws {
        middleware.use(NotFoundMiddleware())
        middleware.use(FileMiddleware(publicDirectory: directory.publicDirectory))
        middleware.use(sessions.middleware)

        views.use(.leaf)

        try routes()
    }
}
