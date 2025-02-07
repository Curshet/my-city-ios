import UIKit
import Combine

protocol AppPhoneCodeCenterTextFieldProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<AppPhoneCodeCenterTextFieldInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AppPhoneCodeCenterTextFieldExternalEvent, Never> { get }
}
