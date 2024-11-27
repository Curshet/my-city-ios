import UIKit
import Combine

protocol ProfileRootHeaderViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<ProfileRootHeaderViewInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<ProfileRootHeaderViewExternalEvent, Never> { get }
}
