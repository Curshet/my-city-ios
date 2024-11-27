import UIKit
import Combine

class ProfileRootCenterViewDataSource: NSObject, ProfileRootCenterViewDataSourceProtocol {

    let internalEventPublisher: PassthroughSubject<[Any], Never>
    let externalEventPublisher: AnyPublisher<ProfileRootCenterViewExternalEvent, Never>
    
    private weak var builder: ProfileBuilderCenterCellProtocol?
    private var items: [Any]?
    private var action: ((ProfileRootCenterViewExternalEvent) -> Void)?
    private let externalPublisher: PassthroughSubject<ProfileRootCenterViewExternalEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(builder: ProfileBuilderCenterCellProtocol?) {
        self.builder = builder
        self.internalEventPublisher = PassthroughSubject<[Any], Never>()
        self.externalPublisher = PassthroughSubject<ProfileRootCenterViewExternalEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init()
        setupObservers()
    }
    
}

// MARK: Private
private extension ProfileRootCenterViewDataSource {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.items = $0
        }.store(in: &subscriptions)
        
        action = { [weak self] in
            self?.externalPublisher.send($0)
        }
    }
    
    func setupCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        lazy var defaultCell = defaultCell(collectionView, indexPath)
        
        switch indexPath.row {
            case 0:
                return builder?.centerUserInfoCell(collectionView, indexPath, items?[indexPath.row], action) ?? defaultCell

            case 1:
                return builder?.centerLogoutCell(collectionView, indexPath, items?[indexPath.row], action) ?? defaultCell

            default:
                return defaultCell
        }
    }

}

// MARK: Protocol
extension ProfileRootCenterViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items?.count ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        setupCell(collectionView, indexPath)
    }
    
}
