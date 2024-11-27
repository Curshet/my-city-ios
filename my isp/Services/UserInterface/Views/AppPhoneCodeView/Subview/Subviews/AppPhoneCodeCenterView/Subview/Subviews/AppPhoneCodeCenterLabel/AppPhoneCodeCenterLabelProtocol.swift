import UIKit
import Combine

protocol AppPhoneCodeCenterLabelProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<AppPhoneCodeCenterLabelInternalEvent, Never> { get }
}
