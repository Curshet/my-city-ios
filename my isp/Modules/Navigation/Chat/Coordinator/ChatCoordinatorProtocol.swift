import Foundation
import Combine

protocol ChatCoordinatorProtocol {
    var internalEventPublisher: PassthroughSubject<AppInteractorActivity, Never> { get }
}
