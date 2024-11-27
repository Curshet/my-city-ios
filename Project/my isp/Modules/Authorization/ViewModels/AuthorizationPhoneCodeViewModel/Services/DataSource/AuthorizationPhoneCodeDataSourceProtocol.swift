import Foundation
import Combine

protocol AuthorizationPhoneCodeDataSourceProtocol {
    var internalEventPublisher: PassthroughSubject<AuthorizationPhoneCodeDataSourceInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AuthorizationPhoneCodeDataSourceExternalEvent, Never> { get }
}
