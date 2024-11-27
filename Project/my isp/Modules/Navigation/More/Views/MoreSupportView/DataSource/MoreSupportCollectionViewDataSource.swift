import UIKit
import Combine

class MoreSupportCollectionViewDataSource: NSObject, MoreSupportCollectionViewDataSourceProtocol {
    
    let internalEventPublisher: PassthroughSubject<[Any], Never>
    let externalEventPublisher: AnyPublisher<MoreSupportViewModelSelectEvent, Never>

    private weak var builder: MoreBuilderSupportCellProtocol?
    private var items: [Any]?
    private var action: ((MoreSupportViewModelSelectEvent) -> Void)?
    private let externalPublisher: PassthroughSubject<MoreSupportViewModelSelectEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(builder: MoreBuilderSupportCellProtocol) {
        self.builder = builder
        self.internalEventPublisher = PassthroughSubject<[Any], Never>()
        self.externalPublisher = PassthroughSubject<MoreSupportViewModelSelectEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init()
        setupObservers()
    }

}

// MARK: Private
private extension MoreSupportCollectionViewDataSource {
    
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
                return builder?.supportPhoneCell(collectionView, indexPath, items?[indexPath.row], action) ?? defaultCell
            
            case 1:
                return builder?.supportMessengersCell(collectionView, indexPath, items?[indexPath.row], action) ?? defaultCell
            
            default:
                return defaultCell
        }
    }

}

// MARK: Protocol
extension MoreSupportCollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items?.count ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        setupCell(collectionView, indexPath)
    }
    
}
