import UIKit
import Combine

protocol AuthorizationViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<AuthorizationViewModelExternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AuthorizationViewModelSelectEvent, Never> { get }
}
