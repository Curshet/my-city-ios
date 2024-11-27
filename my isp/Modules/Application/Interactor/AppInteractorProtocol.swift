import Foundation
import Combine

protocol AppInteractorProtocol {
    var internalEventPublisher: PassthroughSubject<AppInteractorInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<AppInteractorExternalEvent, Never> { get }
}
