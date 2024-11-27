import UIKit
import Combine

protocol AppPhoneCodeViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<AppPhoneCodeViewInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AppPhoneCodeViewExternalEvent, Never> { get }
}
