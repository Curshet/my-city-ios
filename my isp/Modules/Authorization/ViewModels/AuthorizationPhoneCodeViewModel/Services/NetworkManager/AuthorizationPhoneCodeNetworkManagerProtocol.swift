import Foundation
import Combine

protocol AuthorizationPhoneCodeNetworkManagerProtocol {
    var requestPublisher: PassthroughSubject<NetworkManagerRequest, Never> { get }
    var responsePublisher: AnyPublisher<Result<String, NSError>, Never> { get }
}
