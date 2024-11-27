import UIKit
import Combine

protocol AppPhoneCodeHeaderViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<AppPhoneCodeHeaderData, Never> { get }
    var externalEventPublisher: AnyPublisher<Void, Never> { get }
}
