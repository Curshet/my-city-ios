import UIKit
import Combine

protocol AuthorizationPhoneRootCenterTextFieldProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<AuthorizationPhoneRootCenterTextFieldData, Never> { get }
    var externalEventPublisher: AnyPublisher<AuthorizationPhoneRootViewModelActivity, Never> { get }
    var text: String? { get }
}
