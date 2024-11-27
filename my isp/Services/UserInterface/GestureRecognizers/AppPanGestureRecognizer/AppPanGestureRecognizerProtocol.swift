import UIKit
import Combine

protocol AppPanGestureRecognizerProtocol: UIPanGestureRecognizer {
    var publisher: AnyPublisher<AppGestureRecognizerEvent, Never> { get }
}
