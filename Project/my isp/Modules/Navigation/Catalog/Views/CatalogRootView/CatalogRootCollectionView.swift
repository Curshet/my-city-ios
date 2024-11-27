import UIKit
import Combine

class CatalogRootCollectionView: AppCollectionView, CatalogRootCollectionViewProtocol {
    
    let dataPublisher: PassthroughSubject<CatalogRootViewLayout, Never>

    private let customDataSource: CatalogRootCollectionViewDataSourceProtocol
    private let layout: UICollectionViewFlowLayout
    private var subscriptions: Set<AnyCancellable>
    
    init(dataSource: CatalogRootCollectionViewDataSourceProtocol, layout: UICollectionViewFlowLayout) {
        self.customDataSource = dataSource
        self.layout = layout
        self.dataPublisher = PassthroughSubject<CatalogRootViewLayout, Never>()
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
private extension CatalogRootCollectionView {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
    }
    
    func setupObservers() {
        dataPublisher.sink { [weak self] in
            self?.setupLayout($0)
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        alwaysBounceVertical = true
        alwaysBounceHorizontal = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
    }
    
    func setupLayout(_ data: CatalogRootViewLayout) {
        backgroundColor = data.backgroundColor
    }
    
}

// MARK: - CatalogRootViewLayout
struct CatalogRootViewLayout {
    let backgroundColor = UIColor.interfaceManager.themeBackgroundOne()
}
