// Copyright Marcin Krzyżanowski <marcin@krzyzanowskim.com>

import Foundation
import Kitura
import Configuration
import KituraSession
import CloudEnvironment

class Server {
    let cloudEnv = CloudEnv()
    let router: Router

    init(router: Router) {
        self.router = router
    }

    func run() {
        /*
        #if (Linux)
            let certPath = ConfigurationManager.BasePath.project.path.appending("/ssl/dev.swiftplayground.run.cer")
            let keyPath = ConfigurationManager.BasePath.project.path.appending("/ssl/dev.swiftplayground.run.key.pem")
            let serviceSSLConfig = SSLConfig(withCACertificateDirectory: nil, usingCertificateFile: certPath, withKeyFile: keyPath, usingSelfSignedCerts: true)
        #else
            let certPath = ConfigurationManager.BasePath.project.path.appending("/ssl/dev.swiftplayground.run.p12")
            let serviceSSLConfig = SSLConfig(withChainFilePath: certPath, withPassword: "1234", usingSelfSignedCerts: true)
        #endif
        */
        Kitura.addHTTPServer(onPort: cloudEnv.port, with: router) //, withSSL: serviceSSLConfig)
        Kitura.run()
    }
}
