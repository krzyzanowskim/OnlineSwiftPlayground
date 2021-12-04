import Vapor
import Leaf

public func configure(_ app: Application) throws {
    app.http.server.configuration.hostname = "localhost"
    app.http.server.configuration.port = 8080
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease
    try routes(app)
}
