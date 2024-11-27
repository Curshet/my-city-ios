import UIKit
import Combine

protocol DisplayViewControllerProtocol: UIViewController {
    var internalEventPublisher: PassthroughSubject<DisplaySpinnerEvent, Never> { get }
}
