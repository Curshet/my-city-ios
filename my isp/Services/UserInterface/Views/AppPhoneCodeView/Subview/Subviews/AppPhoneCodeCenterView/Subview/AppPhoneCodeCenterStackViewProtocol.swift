import UIKit
import Combine

protocol AppPhoneCodeCenterStackViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<AppPhoneCodeCenterStackViewInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AppPhoneCodeViewExternalEvent, Never> { get }
}
