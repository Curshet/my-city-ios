import UIKit
import Combine

protocol MoreRootCollectionViewDataSourceProtocol: UICollectionViewDataSource {
    var internalEventPublisher: PassthroughSubject<MoreRootViewItems, Never> { get }
    var externalEventPublisher: AnyPublisher<MoreRootViewModelSelectEvent, Never> { get }
}
