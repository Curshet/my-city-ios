import UIKit
import Combine

protocol AppLongPressGestureRecognizerProtocol: UILongPressGestureRecognizer {
    var publisher: AnyPublisher<AppGestureRecognizerEvent, Never> { get }
}
