import Foundation
import Combine

protocol AppPhoneCodeCenterTextFieldDelegateProtocol: AppTextFieldDelegateProtocol {
    var internalEventPublisher: PassthroughSubject<AppPhoneCodeCenterStackTarget, Never> { get }
    var externalEventPublisher: AnyPublisher<AppPhoneCodeCenterTextFieldExternalEvent, Never> { get }
}
