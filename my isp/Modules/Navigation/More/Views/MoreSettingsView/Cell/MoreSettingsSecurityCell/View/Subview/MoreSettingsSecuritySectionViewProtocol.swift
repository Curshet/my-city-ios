import UIKit
import Combine

protocol MoreSettingsSecuritySectionViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<MoreSettingsSecuritySectionData, Never> { get }
    var externalEventPublisher: AnyPublisher<Void, Never> { get }
}
