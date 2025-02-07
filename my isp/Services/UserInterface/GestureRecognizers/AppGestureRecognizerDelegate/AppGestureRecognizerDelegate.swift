import UIKit
import Combine

class AppGestureRecognizerDelegate: NSObject, AppGestureRecognizerDelegateProtocol {
    
    let publisher: AnyPublisher<AppGestureRecognizerEvent, Never>
    let superExternalPublisher: PassthroughSubject<AppGestureRecognizerEvent, Never>
    
    override init() {
        self.superExternalPublisher = PassthroughSubject<AppGestureRecognizerEvent, Never>()
        self.publisher = AnyPublisher(superExternalPublisher)
        super.init()
    }
    
}

// MARK: - AppGestureRecognizerEvent
enum AppGestureRecognizerEvent {
    case touchInside
    case shouldBegin
    case shouldRecognizeSimultaneously(other: UIGestureRecognizer)
    case shouldRequireFailure(other: UIGestureRecognizer)
    case shouldBeRequiredToFail(other: UIGestureRecognizer)
    case shouldReceiveTouch(UITouch)
    case shouldReceivePress(UIPress)
    case shouldReceiveEvent(UIEvent)
}
