import Foundation
import Combine

protocol ProfileRootDataManagerProtocol {
    var internalEventPublisher: PassthroughSubject<ProfileRootDataProcessorInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<ProfileRootDataProcessorExternalEvent, Never> { get }
}
