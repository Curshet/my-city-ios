import Foundation
import Combine

protocol AuthorizationCoordinatorProtocol {
    var internalEventPublisher: PassthroughSubject<AuthorizationCoordinatorInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AuthorizationCoordinatorExternalEvent, Never> { get }
}
