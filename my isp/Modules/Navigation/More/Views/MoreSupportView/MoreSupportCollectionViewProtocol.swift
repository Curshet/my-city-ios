import UIKit
import Combine

protocol MoreSupportCollectionViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<MoreSupportViewData, Never> { get }
    var externalEventPublisher: AnyPublisher<MoreSupportViewModelSelectEvent, Never> { get }
}
