import Foundation
import Combine

protocol IntercomCoordinatorProtocol {
    var internalEventPublisher: PassthroughSubject<AppInteractorActivity, Never> { get }
}
