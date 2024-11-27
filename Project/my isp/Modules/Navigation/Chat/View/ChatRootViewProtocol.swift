import UIKit
import Combine

protocol ChatRootViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<ChatRootViewModelExternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<ChatRootViewModelRequestType, Never> { get }
}
