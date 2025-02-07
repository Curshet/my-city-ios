import UIKit
import Combine

protocol MoreSettingsCollectionViewDataSourceProtocol: UICollectionViewDataSource {
    var internalEventPublisher: PassthroughSubject<[Any], Never> { get }
    var externalEventPublisher: AnyPublisher<MoreSettingsViewModelSelectEvent, Never> { get }
}
