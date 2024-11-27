import UIKit
import Combine

protocol SplashViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<SplashViewModelExternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<Void, Never> { get }
}
