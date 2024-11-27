import UIKit
import Combine

protocol MoreSupportCollectionViewDataSourceProtocol: UICollectionViewDataSource {
    var internalEventPublisher: PassthroughSubject<[Any], Never> { get }
    var externalEventPublisher: AnyPublisher<MoreSupportViewModelSelectEvent, Never> { get }
}
