import UIKit
import Combine

protocol AppOverlayViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<AppOverlayViewInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AppTimeEvent, Never> { get }
}
