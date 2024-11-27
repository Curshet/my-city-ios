import Foundation
import Combine

protocol AppRouteManagerProtocol {
    var internalEventPublisher: PassthroughSubject<AppRouteManagerInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AppRouteManagerExternalEvent, Never> { get }
}
