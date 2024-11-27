import Foundation
import Combine

protocol CatalogRootDataManagerProtocol {
    var internalEventPublisher: PassthroughSubject<CatalogRootDataManagerInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<CatalogRootDataManagerExternalEvent, Never> { get }
}
