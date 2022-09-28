import Vapor
import Leaf
import NIOSSL

public extension Application {
    func configure() throws {
        try http.server.configuration.tlsConfiguration = .makeServerConfiguration(
            certificateChain: NIOSSLCertificate.fromPEMFile(directory.workingDirectory + "/ssl/certificate.crt").map { .certificate($0) },
            privateKey: .privateKey(.init(file: directory.workingDirectory + "/ssl/private.key", format: .pem))
        )

        middleware.use(NotFoundMiddleware())
        middleware.use(FileMiddleware(publicDirectory: directory.publicDirectory))
        middleware.use(sessions.middleware)

        views.use(.leaf)

        try routes()
    }
}
