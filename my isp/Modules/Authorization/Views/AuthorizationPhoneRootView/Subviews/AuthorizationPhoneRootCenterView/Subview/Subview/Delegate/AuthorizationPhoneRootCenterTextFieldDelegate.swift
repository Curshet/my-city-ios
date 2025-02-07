import UIKit
import Combine

class AuthorizationPhoneRootCenterTextFieldDelegate: AppTextFieldDelegate, AuthorizationPhoneRootCenterTextFieldDelegateProtocol {
    
    let externalEventPublisher: AnyPublisher<AuthorizationPhoneRootViewModelActivity, Never>
    
    private let externalPublisher: PassthroughSubject<AuthorizationPhoneRootViewModelActivity, Never>

    override init() {
        self.externalPublisher = PassthroughSubject<AuthorizationPhoneRootViewModelActivity, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        super.init()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string.count <= 1 else {
            externalPublisher.send(.paste)
            return false
        }
        
        switch string {
            case .clear :
                textField.text?.removeLast()
            
            default:
                textField.text?.append(string)
        }

        textField.text = textField.text?.phoneMask(withCode: false)
        externalPublisher.send(.input(textField.text))
        return false
    }
    
}
