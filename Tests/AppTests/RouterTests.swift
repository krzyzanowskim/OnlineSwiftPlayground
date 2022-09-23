import XCTVapor
@testable import App

final class RouterTests: XCTestCase {
    private var app: Application!
    private var viewRenderer: ViewRendererSpy!

    override func setUpWithError() throws {
        app = .init(.testing)
        viewRenderer = ViewRendererSpy(eventLoop: app.eventLoopGroup.next())

        try app.configure()
        app.views.use { _ in self.viewRenderer }
    }

    override func tearDown() {
        app.shutdown()
        app = nil
    }

    func testBasicRoutes() throws {
        try app.test(.GET, "") { response in
            XCTAssertEqual(viewRenderer.requestedTemplate, "index")
            XCTAssertEqual(response.status, .ok)
        }
        try app.test(.GET, "privacy-policy") { response in
            XCTAssertEqual(viewRenderer.requestedTemplate, "privacy-policy")
            XCTAssertEqual(response.status, .ok)
        }
        try app.test(.GET, "letsplay") { response in
            XCTAssertEqual(response.status, .seeOther)
            XCTAssertEqual(response.headers.first(name: "Location"), "/")
        }
        try app.test(.GET, "logout") { response in
            XCTAssertEqual(viewRenderer.requestedTemplate, "logout")
            XCTAssertEqual(response.status, .ok)
        }
    }

    func testLetsPlayStartsPlayground() throws {
        var headers = HTTPHeaders()
        var cookies: HTTPCookies?

        try app.test(.GET, "", headers: headers) { response in
            XCTAssertEqual(viewRenderer.requestedTemplate, "index")
            cookies = response.headers.setCookie
        }

        headers.cookie = cookies

        try app.test(.GET, "letsplay", headers: headers) { response in
            let session = app.sessions.session(for: response.headers.setCookie?.sessionId)
            XCTAssertEqual(session, ["playground": "true"])
            cookies = response.headers.setCookie
        }

        headers.cookie = cookies

        try app.test(.GET, "", headers: headers) { response in
            XCTAssertEqual(viewRenderer.requestedTemplate, "playground")
        }

        try app.test(.GET, "logout", headers: headers) { response in
            let oldSessionId = headers.cookie?.sessionId
            let newSessionId = response.headers.setCookie?.sessionId

            // Check if old session was destroyed
            let oldSession = app.sessions.session(for: oldSessionId)
            XCTAssertNil(oldSession)

            // Check if we have a new session (different from previous one)
            let newSession = app.sessions.session(for: newSessionId)
            XCTAssertNotNil(newSessionId)
            XCTAssertNil(newSession)
            XCTAssertNotEqual(oldSessionId, newSessionId)

            cookies = response.headers.setCookie
        }

        headers.cookie = cookies

        try app.test(.GET, "", headers: headers) { response in
            XCTAssertEqual(viewRenderer.requestedTemplate, "index")
        }
    }
}
