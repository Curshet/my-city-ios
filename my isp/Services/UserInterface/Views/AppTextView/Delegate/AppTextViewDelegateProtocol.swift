import UIKit
import Combine

protocol AppTextViewDelegateProtocol: UITextViewDelegate {
    var publisher: AnyPublisher<AppTextViewDelegateEvent, Never> { get }
}
