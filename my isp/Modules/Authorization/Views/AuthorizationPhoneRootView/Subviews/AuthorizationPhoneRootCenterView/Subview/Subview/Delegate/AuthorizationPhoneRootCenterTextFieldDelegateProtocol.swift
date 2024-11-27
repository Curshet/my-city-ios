import Foundation
import Combine

protocol AuthorizationPhoneRootCenterTextFieldDelegateProtocol: AppTextFieldDelegateProtocol {
    var externalEventPublisher: AnyPublisher<AuthorizationPhoneRootViewModelActivity, Never> { get }
}
