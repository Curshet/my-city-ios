import Foundation
import Combine

protocol IntercomRouterProtocol: AnyObject {
    var internalEventPublisher: PassthroughSubject<AppInteractorActivity, Never> { get }
    var externalEventPublisher: AnyPublisher<AppInteractorActivity, Never> { get }
}
