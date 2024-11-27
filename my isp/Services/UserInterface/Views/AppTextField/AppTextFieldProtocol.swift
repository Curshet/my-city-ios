import UIKit
import Combine

protocol AppTextFieldProtocol: UITextField {
    var publisher: AnyPublisher<AppTextFieldEvent, Never> { get }
    func addTarget(_ event: UIControl.Event...)
    func removeTarget(_ event: UIControl.Event...)
    func configureSelector(_ target: AppTextSelector...)
}
