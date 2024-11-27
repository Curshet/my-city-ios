import UIKit
import Combine

protocol ProfileRootCenterViewDataSourceProtocol: UICollectionViewDataSource {
    var internalEventPublisher: PassthroughSubject<[Any], Never> { get }
    var externalEventPublisher: AnyPublisher<ProfileRootCenterViewExternalEvent, Never> { get }
}
