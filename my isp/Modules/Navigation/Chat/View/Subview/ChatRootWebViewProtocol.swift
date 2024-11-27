import UIKit
import Combine

protocol ChatRootWebViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<ChatRootViewModelExternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<ChatRootViewModelRequestType, Never> { get }
}
