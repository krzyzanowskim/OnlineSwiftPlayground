import Vapor

/// Captures requested view's name
class ViewRendererSpy: ViewRenderer {
    let eventLoop: EventLoop
    var requestedTemplate: String?

    init(eventLoop: EventLoop) {
        self.eventLoop = eventLoop
    }

    func `for`(_ request: Vapor.Request) -> Vapor.ViewRenderer {
        self
    }

    func render<E>(_ name: String, _ context: E) -> EventLoopFuture<View> where E : Encodable {
        requestedTemplate = name
        return eventLoop.future(View(data: .init()))
    }
}
