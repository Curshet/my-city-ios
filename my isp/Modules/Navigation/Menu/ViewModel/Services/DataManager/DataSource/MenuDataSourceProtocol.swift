import Foundation
import Combine

protocol MenuDataSourceProtocol {
    var internalEventPublisher: PassthroughSubject<MenuDataSourceInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<MenuDataSourceExternalEvent, Never> { get }
}
