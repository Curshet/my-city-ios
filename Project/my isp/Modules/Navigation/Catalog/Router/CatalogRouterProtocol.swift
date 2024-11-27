import Foundation
import Combine

protocol CatalogRouterProtocol: AnyObject {
    var internalEventPublisher: PassthroughSubject<CatalogRouterInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<CatalogRouterExternalEvent, Never> { get }
}
