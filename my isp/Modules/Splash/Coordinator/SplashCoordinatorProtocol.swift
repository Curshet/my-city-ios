import Foundation
import Combine

protocol SplashCoordinatorProtocol {
    var internalEventPublisher: PassthroughSubject<Void, Never> { get }
    var externalEventPublisher: AnyPublisher<Void, Never> { get }
}
