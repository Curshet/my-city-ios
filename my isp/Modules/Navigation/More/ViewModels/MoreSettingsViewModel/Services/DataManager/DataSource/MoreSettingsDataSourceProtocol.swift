import Foundation
import Combine

protocol MoreSettingsDataSourceProtocol {
    var internalEventPublisher: PassthroughSubject<MoreSettingsDataSourceInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<MoreSettingsDataSourceExternalEvent, Never> { get }
}
