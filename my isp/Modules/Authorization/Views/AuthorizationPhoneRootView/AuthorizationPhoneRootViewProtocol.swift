import UIKit
import Combine

protocol AuthorizationPhoneRootViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<AuthorizationPhoneRootViewModelExternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AuthorizationPhoneRootViewModelSelectEvent, Never> { get }
}
