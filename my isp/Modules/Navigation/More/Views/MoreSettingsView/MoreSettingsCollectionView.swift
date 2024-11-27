import UIKit
import Combine

class MoreSettingsCollectionView: AppCollectionView, MoreSettingsCollectionViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<MoreSettingsViewModelExternalEvent, Never>
    let externalEventPublisher: AnyPublisher<MoreSettingsViewModelSelectEvent, Never>
    
    private let customDataSource: MoreSettingsCollectionViewDataSourceProtocol
    private let layout: UICollectionViewFlowLayout
    private var subscriptions: Set<AnyCancellable>
    
    init(dataSource: MoreSettingsCollectionViewDataSourceProtocol, layout: UICollectionViewFlowLayout) {
        self.customDataSource = dataSource
        self.layout = layout
        self.internalEventPublisher = PassthroughSubject<MoreSettingsViewModelExternalEvent, Never>()
        self.externalEventPublisher = customDataSource.externalEventPublisher
        self.subscriptions = Set<AnyCancellable>()
        super.init(delegate: nil, layout: layout)
        self.dataSource = customDataSource
        startConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Private
extension MoreSettingsCollectionView {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        alwaysBounceVertical = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        registerCell(type: MoreSettingsSecurityCell.self)
    }
    
    func internalEventHandler(_ event: MoreSettingsViewModelExternalEvent) {
        switch event {
            case .view(let data):
                customDataSource.internalEventPublisher.send(data.items)
                setupLayout(data)
            
            case .update(let data):
                customDataSource.internalEventPublisher.send(data.items)
                reloadItems(at: [data.indexPath])
        }
    }
    
    func setupLayout(_ data: MoreSettingsViewData) {
        contentInset = data.layout.contentInset
        backgroundColor = data.layout.backgroundColor
        layout.minimumLineSpacing = data.layout.minimumLineSpacing
        reloadData()
    }
    
}

// MARK: - MoreSettingsViewLayout
struct MoreSettingsViewLayout {
    let minimumLineSpacing = 10.fitWidth
    let contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 25, right: 0)
    let backgroundColor = UIColor.interfaceManager.themeBackgroundOne()
}
