import Foundation
import Combine

protocol MoreRootDataSourceProtocol {
    var internalEventPublisher: PassthroughSubject<MoreRootDataSourceInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<MoreRootDataSourceExternalEvent, Never> { get }
}
