import UIKit
import Combine

protocol AuthorizationPhoneRootCenterViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<AuthorizationPhoneRootViewModelExternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AuthorizationPhoneRootViewModelSelectEvent, Never> { get }
}
