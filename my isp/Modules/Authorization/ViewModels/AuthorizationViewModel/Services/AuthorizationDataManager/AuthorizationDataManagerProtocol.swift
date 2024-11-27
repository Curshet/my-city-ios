import Foundation
import Combine

protocol AuthorizationDataManagerProtocol {
    var internalEventPublisher: PassthroughSubject<AuthorizationDataManagerInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AuthorizationDataManagerExternalEvent, Never> { get }
    var isLightMode: Bool { get }
}
