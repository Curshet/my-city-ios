import Foundation
import Combine

protocol AuthorizationNetworkManagerProtocol {
    var requestPublisher: PassthroughSubject<AuthorizationNetworkRequest, Never> { get }
    var responsePublisher: AnyPublisher<Result<AuthorizationNetworkData, NSError>, Never> { get }
}
