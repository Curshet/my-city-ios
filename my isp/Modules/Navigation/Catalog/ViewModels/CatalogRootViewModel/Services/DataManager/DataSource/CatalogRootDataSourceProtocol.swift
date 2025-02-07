import Foundation
import Combine

protocol CatalogRootDataSourceProtocol {
    var internalEventPublisher: PassthroughSubject<CatalogRootDataSourceInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<CatalogRootDataSourceExternalEvent, Never> { get }
}
