import Foundation
import Combine

protocol ProfileRootViewModelProtocol {
    var internalEventPublisher: PassthroughSubject<ProfileRootViewModelInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<ProfileRootViewModelExternalEvent, Never> { get }
}
