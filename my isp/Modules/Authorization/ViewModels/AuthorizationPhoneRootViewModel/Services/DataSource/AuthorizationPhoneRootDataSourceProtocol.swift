import Foundation
import Combine

protocol AuthorizationPhoneRootDataSourceProtocol {
    var internalEventPublisher: PassthroughSubject<AuthorizationPhoneRootDataSourceInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AuthorizationPhoneRootDataSourceExternalEvent, Never> { get }
}
