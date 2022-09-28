import Vapor
import Leaf

public struct NotFoundMiddleware: AsyncMiddleware {
    public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        do {
            return try await next.respond(to: request)
        } catch {
            if let error = error as? AbortError, error.status == .notFound {
                request.logger.report(error: error)
                return try await request.view.render("404").encodeResponse(status: .notFound, for: request)
            }

            throw error
        }
    }
}
