import UIKit
import Combine

class AppPhoneCodeCenterTextFieldDelegate: AppTextFieldDelegate, AppPhoneCodeCenterTextFieldDelegateProtocol {

    let internalEventPublisher: PassthroughSubject<AppPhoneCodeCenterStackTarget, Never>
    let externalEventPublisher: AnyPublisher<AppPhoneCodeCenterTextFieldExternalEvent, Never>
    
    private var target: AppPhoneCodeCenterStackTarget?
    private let externalPublisher: PassthroughSubject<AppPhoneCodeCenterTextFieldExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    override init() {
        self.internalEventPublisher = PassthroughSubject<AppPhoneCodeCenterStackTarget, Never>()
        self.externalPublisher = PassthroughSubject<AppPhoneCodeCenterTextFieldExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init()
        setupObservers()
    }
    
    override func textFieldDidChangeSelection(_ textField: UITextField) {
        super.textFieldDidChangeSelection(textField)
        guard let text = textField.text, text.isEmpty() else { return }
        externalPublisher.send(.input(nil))
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        superExternalPublisher.send(.shouldChangeCharacters(range: range, string: string))
        return textEditingHandler(textField, string)
    }
    
}

// MARK: Private
private extension AppPhoneCodeCenterTextFieldDelegate {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.target = $0
        }.store(in: &subscriptions)
    }
    
    func textEditingHandler(_ textField: UITextField, _ string: String) -> Bool {
        guard let target else {
            logger.console(event: .error(info: "OTP text field doesn't have the target value for editing"))
            return false
        }
        
        guard string.isNumeric || string.isEmpty() else {
            return false
        }
        
        guard let text = textField.text else {
            textField.text = string
            return string.isEmpty() ? false : textEditingCompletion(textField)
        }
        
        if !string.isEmpty() && text.isEmpty() || string.count == target.rawValue && text.count < target.rawValue {
            textField.text = string
            return textEditingCompletion(textField)
        }
        
        if !string.isEmpty(), text.count == target.rawValue {
            return false
        }
        
        if string.count > target.rawValue {
            return false
        }
        
        if string.isEmpty(), !text.isEmpty(), text.count <= target.rawValue {
            textField.text?.removeLast()
            return textEditingCompletion(textField)
        }
        
        textField.text?.append(string)
        return textEditingCompletion(textField)
    }
    
    func textEditingCompletion(_ textField: UITextField) -> Bool {
        let array = textField.text?.map { String($0) }
        externalPublisher.send(.input(array))
        let isFinished = array?.count == target?.rawValue
        guard isFinished, let text = textField.text else { return false }
        externalPublisher.send(.validation(text))
        return false
    }
    
}
