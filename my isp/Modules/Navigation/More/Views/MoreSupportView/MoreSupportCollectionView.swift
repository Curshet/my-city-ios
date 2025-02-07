import UIKit
import Combine

class MoreSupportCollectionView: AppCollectionView, MoreSupportCollectionViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<MoreSupportViewData, Never>
    let externalEventPublisher: AnyPublisher<MoreSupportViewModelSelectEvent, Never>
    
    private let customDataSource: MoreSupportCollectionViewDataSourceProtocol
    private let layout: UICollectionViewFlowLayout
    private var subscriptions: Set<AnyCancellable>
    
    init(dataSource: MoreSupportCollectionViewDataSourceProtocol, layout: UICollectionViewFlowLayout) {
        self.customDataSource = dataSource
        self.layout = layout
        self.internalEventPublisher = PassthroughSubject<MoreSupportViewData, Never>()
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
private extension MoreSupportCollectionView {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.customDataSource.internalEventPublisher.send($0.items)
            self?.setupLayout($0)
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        alwaysBounceVertical = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        registerCell(type: MoreSupportPhoneCell.self)
        registerCell(type: MoreSupportMessengersCell.self)
    }
    
    func setupLayout(_ data: MoreSupportViewData) {
        contentInset = data.layout.contentInset
        backgroundColor = data.layout.backgroundColor
        layout.minimumLineSpacing = data.layout.minimumLineSpacing
        reloadData()
    }
    
}

// MARK: - MoreSupportViewLayout
struct MoreSupportViewLayout {
    let minimumLineSpacing = 10.fitWidth
    let contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 25, right: 0)
    let backgroundColor = UIColor.interfaceManager.themeBackgroundOne()
}
