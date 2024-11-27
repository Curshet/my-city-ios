import Foundation
import Combine

protocol MoreSupportDataManagerProtocol {
    var internalEventPublisher: PassthroughSubject<MoreSupportDataManagerInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<MoreSupportDataManagerExternalEvent, Never> { get }
}
