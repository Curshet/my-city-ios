import UIKit
import Combine

class AppScrollView: UIScrollView {
    
    private let customDelegate: AppScrollViewDelegateProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(frame: CGRect = .zero, delegate: AppScrollViewDelegateProtocol) {
        self.customDelegate = delegate
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: frame)
        self.delegate = customDelegate
        setupRootObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupRootObservers() {
        customDelegate.publishеr.sink { [weak self] in
            self?.delegateEvent($0)
        }.store(in: &subscriptions)
    }
    
    func delegateEvent(_ event: AppScrollViewDelegateEvent) {}
    
}
