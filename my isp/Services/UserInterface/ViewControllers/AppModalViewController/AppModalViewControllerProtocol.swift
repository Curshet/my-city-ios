import UIKit
import Combine

protocol AppModalViewControllerProtocol: UIViewController {
    var publisher: AnyPublisher<AppGestureRecognizerEvent, Never> { get }
}
