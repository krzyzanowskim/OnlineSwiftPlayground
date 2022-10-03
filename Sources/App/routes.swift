import Vapor

extension Application {
    func routes() throws {
        try register(collection: APIController())
        try register(collection: FrontEndController())
    }
}
