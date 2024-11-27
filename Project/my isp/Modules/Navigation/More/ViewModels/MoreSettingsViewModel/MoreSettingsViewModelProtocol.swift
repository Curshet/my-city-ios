import Foundation
import Combine

protocol MoreSettingsViewModelProtocol {
    var internalEventPublisher: PassthroughSubject<MoreSettingsViewModelInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<MoreSettingsViewModelExternalEvent, Never> { get }
}
