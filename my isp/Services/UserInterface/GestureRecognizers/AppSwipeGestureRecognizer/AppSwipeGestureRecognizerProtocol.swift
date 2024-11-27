import UIKit
import Combine

protocol AppSwipeGestureRecognizerProtocol: UISwipeGestureRecognizer {
    var publisher: AnyPublisher<AppGestureRecognizerEvent, Never> { get }
}
