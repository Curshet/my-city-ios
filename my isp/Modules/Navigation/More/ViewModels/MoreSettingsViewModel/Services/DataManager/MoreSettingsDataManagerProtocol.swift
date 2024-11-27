import Foundation
import Combine

protocol MoreSettingsDataManagerProtocol {
    var internalEventPublisher: PassthroughSubject<MoreSettingsDataManagerInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<MoreSettingsDataManagerExternalEvent, Never> { get }
}
