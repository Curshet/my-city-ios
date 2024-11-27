import Foundation
import Combine

protocol AuthorizationViewModelProtocol {
    var internalEventPublisher: PassthroughSubject<AuthorizationViewModelInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AuthorizationViewModelExternalEvent, Never> { get }
    var isLightMode: Bool { get }
}
