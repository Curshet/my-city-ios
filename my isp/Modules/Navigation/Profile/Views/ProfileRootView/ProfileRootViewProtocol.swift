import UIKit
import Combine

protocol ProfileRootViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<ProfileRootViewModelExternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<ProfileRootViewModelSelectEvent, Never> { get }
}
