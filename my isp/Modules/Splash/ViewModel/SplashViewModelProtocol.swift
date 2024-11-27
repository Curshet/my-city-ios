import Foundation
import Combine

protocol SplashViewModelProtocol {
    var internalEventPublisher: PassthroughSubject<SplashViewModelInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<SplashViewModelExternalEvent, Never> { get }
}
