import UIKit
import Combine

class AppCollectionView: UICollectionView {
    
    private let customDelegate: AppCollectionViewDelegateProtocol
    private var rootSubscriptions: Set<AnyCancellable>
    
    init(delegate: AppCollectionViewDelegateProtocol, layout: UICollectionViewLayout) {
        self.customDelegate = delegate
        self.rootSubscriptions = Set<AnyCancellable>()
        super.init(frame: .zero, collectionViewLayout: layout)
        self.delegate = customDelegate
        setupRootObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupRootObservers() {
        customDelegate.collectionExternalPublisher.sink { [weak self] in
            self?.delegateEvent($0)
        }.store(in: &rootSubscriptions)
    }
    
    func delegateEvent(_ event: AppCollectionViewDelegateEventType) {}
    
}
