import UIKit
import Combine

protocol ProfileRootCenterViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<ProfileRootCenterViewInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<ProfileRootCenterViewExternalEvent, Never> { get }
}
