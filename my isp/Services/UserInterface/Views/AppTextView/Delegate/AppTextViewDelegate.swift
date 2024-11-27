import UIKit
import Combine

class AppTextViewDelegate: NSObject, AppTextViewDelegateProtocol {
    
    let publisher: AnyPublisher<AppTextViewDelegateEvent, Never>
    let superExternalPublisher: PassthroughSubject<AppTextViewDelegateEvent, Never>
    
    override init() {
        self.superExternalPublisher = PassthroughSubject<AppTextViewDelegateEvent, Never>()
        self.publisher = AnyPublisher(superExternalPublisher)
        super.init()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        superExternalPublisher.send(.didBeginEditing)
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        superExternalPublisher.send(.didEndEditing)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        superExternalPublisher.send(.didChange)
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        superExternalPublisher.send(.didChangeSelection)
    }

}

// MARK: - AppTextViewDelegateEvent
enum AppTextViewDelegateEvent: Equatable {
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
