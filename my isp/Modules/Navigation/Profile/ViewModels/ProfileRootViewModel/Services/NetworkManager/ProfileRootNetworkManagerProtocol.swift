import Foundation
import Combine

protocol ProfileRootNetworkManagerProtocol {
    var internalEventPublisher: PassthroughSubject<Void, Never> { get }
    var externalEventPublisher: AnyPublisher<Decodable, NSError> { get }
}
