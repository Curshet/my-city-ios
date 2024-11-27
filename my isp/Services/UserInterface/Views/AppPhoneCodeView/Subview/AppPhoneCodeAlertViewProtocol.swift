import UIKit
import Combine

protocol AppPhoneCodeAlertViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<AppPhoneCodeViewInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AppPhoneCodeViewExternalEvent, Never> { get }
}
