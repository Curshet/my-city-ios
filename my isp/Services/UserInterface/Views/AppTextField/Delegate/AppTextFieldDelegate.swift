import UIKit
import Combine

class AppTextFieldDelegate: NSObject, AppTextFieldDelegateProtocol {
    
    let publisher: AnyPublisher<AppTextFieldDelegateEvent, Never>
    let superExternalPublisher: PassthroughSubject<AppTextFieldDelegateEvent, Never>
    
    override init() {
        self.superExternalPublisher = PassthroughSubject<AppTextFieldDelegateEvent, Never>()
        self.publisher = AnyPublisher(superExternalPublisher)
        super.init()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        superExternalPublisher.send(.didBeginEditing)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        superExternalPublisher.send(.didEndEditing)
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        superExternalPublisher.send(.didEndEditingReason(reason: reason))
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        superExternalPublisher.send(.didChangeSelection)
    }
    
}

// MARK: - AppTextFieldDelegateEvent
enum AppTextFieldDelegateEvent: Equatable {
    case shouldBeginEditing
    case shouldEndEditing
    case shouldClear
    case shouldReturn
    case shouldChangeCharacters(range: NSRange, string: String)
    case didBeginEditing
    case didEndEditing
    case didEndEditingReason(reason: UITextField.DidEndEditingReason)
    case didChangeSelection
}
