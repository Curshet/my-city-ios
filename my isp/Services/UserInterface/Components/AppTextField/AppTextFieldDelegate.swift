import UIKit
import Combine

class AppTextFieldDelegate: MetricProtocol, AppTextFieldDelegateProtocol {
    
    var textExternalPublisher: AnyPublisher<AppTextFieldDelegateEvent, Never> {
        textInternalPublisher.eraseToAnyPublisher()
    }
    
    let textInternalPublisher = PassthroughSubject<AppTextFieldDelegateEvent, Never>()

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textInternalPublisher.send(.didBeginEditing)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textInternalPublisher.send(.didEndEditing)
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        textInternalPublisher.send(.didEndEditingReason(reason: reason))
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textInternalPublisher.send(.didChangeSelection)
    }
    
}

// MARK: AppTextFieldDelegateEvent
enum AppTextFieldDelegateEvent {
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

// MARK: AppTextFieldDelegateProtocol
protocol AppTextFieldDelegateProtocol: UITextFieldDelegate {
    var textExternalPublisher: AnyPublisher<AppTextFieldDelegateEvent, Never> { get }
}
