import Foundation
import Combine

protocol MoreRootDataManagerProtocol {
    var internalEventPublisher: PassthroughSubject<MoreRootDataManagerInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<MoreRootDataManagerExternalEvent, Never>  { get }
}
