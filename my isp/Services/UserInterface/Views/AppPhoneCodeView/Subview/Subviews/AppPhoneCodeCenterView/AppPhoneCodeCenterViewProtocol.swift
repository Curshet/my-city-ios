import UIKit
import Combine

protocol AppPhoneCodeCenterViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<AppPhoneCodeViewInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AppPhoneCodeViewExternalEvent, Never> { get }
}
