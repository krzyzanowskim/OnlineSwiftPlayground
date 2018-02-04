// Copyright Marcin Krzyżanowski <marcin@krzyzanowskim.com>

import LoggerAPI
import Kitura
import KituraStencil
import Credentials
import CredentialsGitHub
import Cryptor
import Foundation

func setupCredentials(router: Router) throws -> Bool {
    guard let githubConfig = Config.shared["github"] else {
        Log.warning("Unable to load config/github.json setup. Authorisation disabled.")
        return false
    }

    let githubCredentials = CredentialsGitHub(clientId: githubConfig["clientId"] as! String,
                                              clientSecret: githubConfig["clientSecret"] as! String,
                                              callbackUrl: "", // callbackUrl is ignored by the GitHub anyway
                                              userAgent: "SwiftPlayground.run",
                                              options: ["scopes": ["user:email"]])

    let credentials = Credentials()
    credentials.register(plugin: githubCredentials)
    credentials.options["state"] = Data(bytes: try Random.generate(byteCount: 20)).base64EncodedString()
    credentials.options["allow_signup"] = "true"

    router.get("/login/github", handler: credentials.authenticate(credentialsType: githubCredentials.name, successRedirect: "/", failureRedirect: "/"))
    router.get("/login/github/callback", handler: credentials.authenticate(credentialsType: githubCredentials.name, successRedirect: "/", failureRedirect: "/"))

    router.get("/logout") { [unowned credentials] request, response, next in
        credentials.logOut(request: request)
        next()
    }

    return true
}
