import Foundation
import Combine

protocol ChatRootDataSourceProtocol {
    var internalEventPublisher: PassthroughSubject<ChatDataSourceInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<ChatDataSourceExternalEvent, Never> { get }
}
