import UIKit
import Combine

class AppCollectionView: UICollectionView {
    
    private let customDelegate: AppCollectionViewDelegateProtocol?
    private var subscriptions: Set<AnyCancellable>
    
    init(delegate: AppCollectionViewDelegateProtocol?, frame: CGRect = .zero, layout: UICollectionViewLayout) {
        self.customDelegate = delegate
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: frame, collectionViewLayout: layout)
        self.delegate = customDelegate
        self.isPrefetchingEnabled = true
        registerCell(type: UICollectionViewCell.self)
        setupRootObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupRootObservers() {
        customDelegate?.publisher.sink { [weak self] in
            self?.delegateEvent($0)
        }.store(in: &subscriptions)
    }
    
    func delegateEvent(_ event: AppCollectionViewDelegateEventType) {}
    
}
