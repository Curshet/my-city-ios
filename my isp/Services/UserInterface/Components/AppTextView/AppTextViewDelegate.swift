import UIKit
import Combine

class AppTextViewDelegate: MetricProtocol, AppTextViewDelegateProtocol {
    
    var textExternalPublisher: AnyPublisher<AppTextViewDelegateEvent, Never> {
        textInternalPublisher.eraseToAnyPublisher()
    }
    
    let textInternalPublisher = PassthroughSubject<AppTextViewDelegateEvent, Never>()
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textInternalPublisher.send(.didBeginEditing)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        textInternalPublisher.send(.didEndEditing)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textInternalPublisher.send(.didChange)
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        textInternalPublisher.send(.didChangeSelection)
    }

}

// MARK: AppTextViewDelegateEvent
enum AppTextViewDelegateEvent {
    case shouldBeginEditing
    case shouldEndEditing
    case shouldChangeText(range: NSRange, text: String)
    case shouldInteract(url: URL, range: NSRange, interaction: UITextItemInteraction)
    case shouldInteract(attachment: NSTextAttachment, range: NSRange, interaction: UITextItemInteraction)
    case didBeginEditing
    case didEndEditing
    case didChange
    case didChangeSelection
}

// MARK: AppTextViewDelegateProtocol
protocol AppTextViewDelegateProtocol: UITextViewDelegate {
    var textExternalPublisher: AnyPublisher<AppTextViewDelegateEvent, Never> { get }
}
