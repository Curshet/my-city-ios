import Foundation
import Combine

protocol MoreRouterProtocol: AnyObject {
    var internalEventPublisher: PassthroughSubject<MoreRouterInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AppInteractorActivity, Never> { get }
}
