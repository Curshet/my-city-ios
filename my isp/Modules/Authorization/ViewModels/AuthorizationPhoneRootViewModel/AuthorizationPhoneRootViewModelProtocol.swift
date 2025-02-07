import Foundation
import Combine

protocol AuthorizationPhoneRootViewModelProtocol {
    var internalEventPublisher: PassthroughSubject<AuthorizationPhoneRootViewModelInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AuthorizationPhoneRootViewModelExternalEvent, Never> { get }
}
