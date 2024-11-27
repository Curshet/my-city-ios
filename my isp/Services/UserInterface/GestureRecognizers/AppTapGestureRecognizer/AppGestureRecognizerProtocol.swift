import UIKit
import Combine

protocol AppTapGestureRecognizerProtocol: UITapGestureRecognizer {
    var publisher: AnyPublisher<AppGestureRecognizerEvent, Never> { get }
}
