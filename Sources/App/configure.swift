import Vapor
import Leaf
import NIOSSL

public extension Application {
    func configure() throws {
        http.server.configuration.reuseAddress = true

        if let certPath = Environment.get("SSL_CERT_PATH"), let keyPath = Environment.get("SSL_KEY_PATH") {
            try http.server.configuration.tlsConfiguration = .makeServerConfiguration(
                certificateChain: NIOSSLCertificate.fromPEMFile(certPath).map { .certificate($0) },
                privateKey: .privateKey(.init(file: keyPath, format: .pem))
            )
            http.server.configuration.port = 443
        }

        middleware.use(NotFoundMiddleware())
        middleware.use(FileMiddleware(publicDirectory: directory.publicDirectory))
        middleware.use(sessions.middleware)

        views.use(.leaf)

        try routes()
    }
}
