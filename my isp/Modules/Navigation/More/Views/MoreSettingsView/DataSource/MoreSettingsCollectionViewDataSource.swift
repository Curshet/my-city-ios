import UIKit
import Combine

class MoreSettingsCollectionViewDataSource: NSObject, MoreSettingsCollectionViewDataSourceProtocol {
    
    let internalEventPublisher: PassthroughSubject<[Any], Never>
    let externalEventPublisher: AnyPublisher<MoreSettingsViewModelSelectEvent, Never>
    
    private weak var builder: MoreBuilderSettingsCellProtocol?
    private var items: [Any]?
    private var action: ((MoreSettingsViewModelSelectEvent) -> Void)?
    private let externalPublisher: PassthroughSubject<MoreSettingsViewModelSelectEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(builder: MoreBuilderSettingsCellProtocol) {
        self.builder = builder
        self.internalEventPublisher = PassthroughSubject<[Any], Never>()
        self.externalPublisher = PassthroughSubject<MoreSettingsViewModelSelectEvent, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init()
        setupObservers()
    }
    
}

// MARK: Private
private extension MoreSettingsCollectionViewDataSource {
    
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
                return builder?.securityCell(collectionView, indexPath, items?[indexPath.row], action) ?? defaultCell
            
            default:
                return defaultCell
        }
    }
    
}

// MARK: Protocol
extension MoreSettingsCollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items?.count ?? .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        setupCell(collectionView, indexPath)
    }
    
}
