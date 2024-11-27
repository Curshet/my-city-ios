import UIKit
import Combine

class AppScrollView: UIScrollView {
    
    private let customDelegate: AppScrollViewDelegateProtocol
    private var rootSubscriptions: Set<AnyCancellable>
    
    init(delegate: AppScrollViewDelegateProtocol) {
        self.customDelegate = delegate
        self.rootSubscriptions = Set<AnyCancellable>()
        super.init(frame: .zero)
        self.delegate = customDelegate
        setupRootObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupRootObservers() {
        customDelegate.scrollExternalPublisher.sink { [weak self] in
            self?.delegateEvent($0)
        }.store(in: &rootSubscriptions)
    }
    
    func delegateEvent(_ event: AppScrollViewDelegateEvent) {}
    
}
