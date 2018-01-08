// Copyright Marcin Krzyżanowski <marcin@krzyzanowskim.com>

import LoggerAPI
import Kitura
import KituraStencil
import Credentials
import CredentialsGitHub
import Cryptor
import SwiftyJSON
import Foundation

func setupCredentials(router: Router) throws -> Credentials? {
    guard let githubConfig = Config.shared["github"] else {
        Log.warning("Unable to load config/github.json setup. Authorisation disabled.")
        return nil
    }

    let githubCredentials = CredentialsGitHub(clientId: githubConfig["clientId"] as! String,
                                              clientSecret: githubConfig["clientSecret"] as! String,
                                              callbackUrl: "", // callbackUrl is ignored by the GitHub anyway
                                              userAgent: "SwiftPlayground.run",
                                              options: ["scopes": ["user:email"]])

    let credentials = Credentials()
    credentials.register(plugin: githubCredentials)
    credentials.options["failureRedirect"] = "/signin"
    credentials.options["successRedirect"] = "/"
    credentials.options["state"] = Data(bytes: try Random.generate(byteCount: 20)).base64EncodedString()
    credentials.options["allow_signup"] = "true"

    router.get("/login/github") { (request, response, next) in
        let authRouterHandler = credentials.authenticate(credentialsType: githubCredentials.name)
        try authRouterHandler(request, response, next)
    }

    router.get("/login/github/callback", handler: credentials.authenticate(credentialsType: githubCredentials.name))

    #if !Xcode
    router.all("/", allowPartialMatch: false, middleware: credentials)
    #endif

    return credentials
}
