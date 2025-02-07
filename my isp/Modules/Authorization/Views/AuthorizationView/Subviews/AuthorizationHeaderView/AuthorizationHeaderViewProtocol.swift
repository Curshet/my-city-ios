import UIKit
import Combine

protocol AuthorizationHeaderViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<AuthorizationHeaderData, Never> { get }
}
