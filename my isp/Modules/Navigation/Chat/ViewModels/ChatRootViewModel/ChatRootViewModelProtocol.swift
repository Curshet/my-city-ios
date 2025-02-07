import Foundation
import Combine

protocol ChatRootViewModelProtocol {
    var internalEventPublisher: PassthroughSubject<ChatRootViewModelInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<ChatRootViewModelExternalEvent, Never> { get }
}
