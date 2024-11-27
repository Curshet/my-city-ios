import UIKit
import Combine

protocol MoreSettingsCollectionViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<MoreSettingsViewModelExternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<MoreSettingsViewModelSelectEvent, Never> { get }
}
