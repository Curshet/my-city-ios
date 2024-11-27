import UIKit
import Combine

protocol AppTextViewProtocol: UITextView {
    var publisher: AnyPublisher<AppTextViewEvent, Never> { get }
    func configureSelector(_ target: AppTextSelector...)
}
