import Foundation
import Combine

protocol MoreRootNetworkManagerProtocol {
    var internalEventPublisher: PassthroughSubject<NetworkManagerRequest, Never> { get }
    var externalEventPublisher: AnyPublisher<Result<MoreSupportContacts, NSError>, Never> { get }
}
