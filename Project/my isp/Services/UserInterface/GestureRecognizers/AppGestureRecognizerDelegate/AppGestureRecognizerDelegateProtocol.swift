import UIKit
import Combine

protocol AppGestureRecognizerDelegateProtocol: UIGestureRecognizerDelegate {
    var publisher: AnyPublisher<AppGestureRecognizerEvent, Never> { get }
}
