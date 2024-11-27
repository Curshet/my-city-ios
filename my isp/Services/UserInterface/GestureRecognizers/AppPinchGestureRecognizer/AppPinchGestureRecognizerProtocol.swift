import UIKit
import Combine

protocol AppPinchGestureRecognizerProtocol: UIPinchGestureRecognizer {
    var publisher: AnyPublisher<AppGestureRecognizerEvent, Never> { get }
}
