import UIKit
import Combine

class MoreRootCollectionView: AppCollectionView, MoreRootCollectionViewProtocol {
    
    let internalEventPublisher: PassthroughSubject<MoreRootViewData, Never>
    let externalEventPublisher: AnyPublisher<MoreRootViewModelSelectEvent, Never>

    private let customDataSource: MoreRootCollectionViewDataSourceProtocol
    private let layout: UICollectionViewFlowLayout
    private var subscriptions: Set<AnyCancellable>
    
    init(delegate: AppCollectionViewDelegateProtocol, dataSource: MoreRootCollectionViewDataSourceProtocol, layout: UICollectionViewFlowLayout) {
        self.customDataSource = dataSource
        self.layout = layout
        self.internalEventPublisher = PassthroughSubject<MoreRootViewData, Never>()
        self.externalEventPublisher = customDataSource.externalEventPublisher
        self.subscriptions = Set<AnyCancellable>()
        super.init(delegate: delegate, layout: layout)
        self.dataSource = customDataSource
        startConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// MARK: Private
private extension MoreRootCollectionView {

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
        registerCell(type: MoreRootNavigationCell.self)
        registerCell(type: MoreRootSystemInfoCell.self)
    }
    
    func setupLayout(_ data: MoreRootViewData) {
        contentInset = data.layout.contentInset
        backgroundColor = data.layout.backgroundColor
        layout.minimumLineSpacing = data.layout.minimumLineSpacing
        reloadData()
    }
    
}

// MARK: - MoreRootViewLayout
struct MoreRootViewLayout {
    let minimumLineSpacing = 10.fitWidth
    let contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 25, right: 0)
    let backgroundColor = UIColor.interfaceManager.themeBackgroundOne()
}
