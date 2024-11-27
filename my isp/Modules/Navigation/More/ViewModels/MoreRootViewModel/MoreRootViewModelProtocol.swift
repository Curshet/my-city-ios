import Foundation
import Combine

protocol MoreRootViewModelProtocol {
    var internalEventPublisher: PassthroughSubject<MoreRootViewModelInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<MoreRootViewData, Never> { get }
}
