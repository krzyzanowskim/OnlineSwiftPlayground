import Vapor

extension HTTPCookies {
    var sessionId: SessionID? {
        (self["vapor-session"]?.string).map(SessionID.init(string:))
    }
}

extension Application.Sessions {
    func session(for cookies: HTTPCookies?) -> [String: String]? {
        session(for: cookies?.sessionId)
    }

    func session(for sessionId: SessionID?) -> [String: String]? {
        sessionId.flatMap { sessionId in
            memory.storage.sessions[sessionId]?.snapshot
        }
    }
}
