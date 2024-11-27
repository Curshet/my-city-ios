import UIKit
import Combine

protocol AuthorizationCenterViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<AuthorizationViewModelExternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AuthorizationViewModelSelectEvent, Never> { get }
}
