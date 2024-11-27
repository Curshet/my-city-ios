import UIKit
import Combine

protocol DisplayWindowProtocol: UIWindow {
    var internalEventPublisher: PassthroughSubject<DisplaySpinnerEvent, Never> { get }
}
