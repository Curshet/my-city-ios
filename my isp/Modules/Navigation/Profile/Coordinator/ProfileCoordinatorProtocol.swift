import Foundation
import Combine

protocol ProfileCoordinatorProtocol {
    var internalEventPublisher: PassthroughSubject<AppInteractorActivity, Never> { get }
    var externalEventPublisher: AnyPublisher<Void, Never> { get }
}
