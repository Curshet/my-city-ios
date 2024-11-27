import UIKit
import Combine

protocol AuthorizationPhoneRootHeaderViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<AuthorizationPhoneRootHeaderData, Never> { get }
}
