import UIKit
import Combine

protocol AuthorizationPhoneRootCenterTextViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<AuthorizationPhoneRootViewModelExternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AuthorizationPhoneRootViewModelActivity, Never> { get }
    var text: String? { get }
}
