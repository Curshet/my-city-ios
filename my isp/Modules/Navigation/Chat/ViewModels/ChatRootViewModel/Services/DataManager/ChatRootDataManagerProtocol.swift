import Foundation
import Combine

protocol ChatRootDataManagerProtocol {
    var internalEventPublisher: PassthroughSubject<ChatRootDataManagerInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<ChatRootDataManagerExternalEvent, Never> { get }
}
