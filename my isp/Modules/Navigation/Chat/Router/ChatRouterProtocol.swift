import Foundation
import Combine

protocol ChatRouterProtocol: AnyObject {
    var internalEventPublisher: PassthroughSubject<ChatRouterInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AppInteractorActivity, Never> { get }
}
