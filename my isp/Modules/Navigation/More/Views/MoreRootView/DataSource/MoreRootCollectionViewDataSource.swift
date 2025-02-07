import UIKit
import Combine

class MoreRootCollectionViewDataSource: NSObject, MoreRootCollectionViewDataSourceProtocol {
    
    let internalEventPublisher: PassthroughSubject<MoreRootViewItems, Never>
    let externalEventPublisher: AnyPublisher<MoreRootViewModelSelectEvent, Never>
    
    private weak var builder: MoreBuilderRootCellProtocol?
    private weak var dataCache: MoreRootDataCacheItemsProtocol?
    private var action: ((MoreRootViewModelSelectEvent) -> Void)?
    private let externalPublisher: PassthroughSubject<MoreRootViewModelSelectEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(builder: MoreBuilderRootCellProtocol, dataCache: MoreRootDataCacheItemsProtocol) {
        self.builder = builder
        self.dataCache = dataCache
        self.internalEventPublisher = PassthroughSubject<MoreRootViewItems, Never>()
        self.externalPublisher = PassthroughSubject<MoreRootViewModelSelectEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init()
        setupObservers()
    }
    
}

// MARK: Private
private extension MoreRootCollectionViewDataSource {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.dataCache?.saveData($0)
        }.store(in: &subscriptions)
        
        action = { [weak self] in
            self?.externalPublisher.send($0)
        }
    }
    
    func setupCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        lazy var defaultCell = defaultCell(collectionView, indexPath)
        
        switch indexPath.row {
            case 0...2:
                return builder?.rootNavigationCell(collectionView, indexPath, dataCache?.items?[indexPath.row], action) ?? defaultCell
            
            case 3:
                return builder?.rootSystemInfoCell(collectionView, indexPath, dataCache?.items?[indexPath.row], action) ?? defaultCell
            
            default:
                return defaultCell
        }
    }
    
}

// MARK: Protocol
extension MoreRootCollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataCache?.items?.count ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        setupCell(collectionView, indexPath)
    }
    
}
