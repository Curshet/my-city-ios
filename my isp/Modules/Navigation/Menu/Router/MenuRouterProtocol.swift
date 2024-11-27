import Foundation
import Combine

protocol MenuRouterProtocol: AnyObject {
    var internalEventPublisher: PassthroughSubject<MenuRouterInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<MenuRouterExternalEvent, Never> { get }
}
