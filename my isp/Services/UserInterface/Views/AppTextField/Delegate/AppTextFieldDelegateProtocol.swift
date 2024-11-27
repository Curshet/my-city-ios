import UIKit
import Combine

protocol AppTextFieldDelegateProtocol: UITextFieldDelegate {
    var publisher: AnyPublisher<AppTextFieldDelegateEvent, Never> { get }
}
