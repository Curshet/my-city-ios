import Foundation
import Combine

protocol AuthorizationPhoneCodeViewModelProtocol {
    var internalEventPublisher: PassthroughSubject<AuthorizationPhoneCodeViewModelInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AppPhoneCodeViewInternalEvent, Never> { get }
}
