import Foundation
import Combine

protocol AuthorizationRouterProtocol: AnyObject {
    var internalEventPublisher: PassthroughSubject<AuthorizationRouterInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AuthorizationRouterExternalEvent, Never> { get }
}
