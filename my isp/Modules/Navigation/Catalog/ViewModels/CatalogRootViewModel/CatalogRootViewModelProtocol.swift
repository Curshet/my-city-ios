import Foundation
import Combine

protocol CatalogRootViewModelProtocol {
    var internalEventPublisher: PassthroughSubject<CatalogRootViewModelInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<CatalogRootViewLayout, Never> { get }
}
