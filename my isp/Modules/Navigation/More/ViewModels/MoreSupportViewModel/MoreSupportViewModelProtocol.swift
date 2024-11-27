import Foundation
import Combine

protocol MoreSupportViewModelProtocol {
    var internalEventPublisher: PassthroughSubject<MoreSupportViewModelInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<MoreSupportViewData, Never> { get }
}
