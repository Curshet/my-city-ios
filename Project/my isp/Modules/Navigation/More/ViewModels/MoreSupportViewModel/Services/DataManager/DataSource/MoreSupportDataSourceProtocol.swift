import Foundation
import Combine

protocol MoreSupportDataSourceProtocol {
    var internalEventPublisher: PassthroughSubject<MoreSupportDataSourceInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<MoreSupportDataSourceExternalEvent, Never> { get }
}
