import Foundation
import Combine

protocol CatalogCoordinatorProtocol {
    var internalEventPublisher: PassthroughSubject<AppInteractorActivity, Never> { get }
    var externalEventPublisher: AnyPublisher<Void, Never> { get }
}
