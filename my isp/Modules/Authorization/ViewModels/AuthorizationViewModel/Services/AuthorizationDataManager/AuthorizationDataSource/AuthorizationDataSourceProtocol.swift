import Foundation
import Combine

protocol AuthorizationDataSourceProtocol {
    var internalEventPublisher: PassthroughSubject<AuthorizationDataSourceInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AuthorizationDataSourceExternalEvent, Never> { get }
    var isLightMode: Bool { get }
}
