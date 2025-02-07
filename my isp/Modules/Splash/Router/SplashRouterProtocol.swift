import Foundation
import Combine

protocol SplashRouterProtocol: AnyObject {
    var internalEventPublisher: PassthroughSubject<SplashRouterInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<SplashRouterExternalEvent, Never> { get }
}
