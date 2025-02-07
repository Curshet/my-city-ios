import Foundation
import Combine

protocol CatalogRootNetworkManagerProtocol {
    var internalEventPublisher: PassthroughSubject<CatalogRootNetworkInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<Result<CatalogRootNetworkManagerResponse, CatalogRootNetworkManagerError>, Never> { get }
}
