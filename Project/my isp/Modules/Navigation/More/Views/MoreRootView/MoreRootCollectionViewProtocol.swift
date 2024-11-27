import UIKit
import Combine

protocol MoreRootCollectionViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<MoreRootViewData, Never> { get }
    var externalEventPublisher: AnyPublisher<MoreRootViewModelSelectEvent, Never> { get }
}
