import Foundation
import Combine

protocol ProfileRouterProtocol: AnyObject {
    var internalEventPublisher: PassthroughSubject<ProfileRouterInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<ProfileRouterExternalEvent, Never> { get }
}
