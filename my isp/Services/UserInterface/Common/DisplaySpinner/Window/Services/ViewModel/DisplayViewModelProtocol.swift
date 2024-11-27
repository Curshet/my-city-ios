import Foundation
import Combine

protocol DisplayViewModelProtocol: AnyObject {
    var internalEventPublisher: PassthroughSubject<DisplayViewModelInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<DisplayViewModelExternalEvent, Never> { get }
}
