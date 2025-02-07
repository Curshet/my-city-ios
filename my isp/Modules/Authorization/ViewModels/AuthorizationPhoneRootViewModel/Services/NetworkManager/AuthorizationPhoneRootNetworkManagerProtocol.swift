import Foundation
import Combine

protocol AuthorizationPhoneRootNetworkManagerProtocol {
    var requestPublisher: PassthroughSubject<AuthorizationPhoneRootNetworkRequest, Never> { get }
    var responsePublisher: AnyPublisher<Result<AuthorizationPhoneRootResponseData, NSError>, Never> { get }
}
