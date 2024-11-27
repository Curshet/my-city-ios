import Foundation
import Combine

protocol MenuCoordinatorProtocol {
    var internalEventPublisher: PassthroughSubject<MenuCoordinatorInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<MenuCoordinatorExternalEvent, Never> { get }
}
