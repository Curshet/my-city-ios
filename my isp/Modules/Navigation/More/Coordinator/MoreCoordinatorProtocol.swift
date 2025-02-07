import Foundation
import Combine

protocol MoreCoordinatorProtocol {
    var internalEventPublisher: PassthroughSubject<AppInteractorActivity, Never> { get }
}
