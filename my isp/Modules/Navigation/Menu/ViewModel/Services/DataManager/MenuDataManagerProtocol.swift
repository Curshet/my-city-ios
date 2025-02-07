import Foundation
import Combine

protocol MenuDataManagerProtocol {
    var internalEventPublisher: PassthroughSubject<MenuDataManagerInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<MenuDataManagerExternalEvent, Never> { get }
}
