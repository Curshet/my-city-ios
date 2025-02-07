import UIKit
import Combine

protocol AuthorizationPhoneRootCenterTextRightViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<AuthorizationPhoneRootCenterTextRightViewData, Never> { get }
    var externalEventPublisher: AnyPublisher<Void, Never> { get }
}
