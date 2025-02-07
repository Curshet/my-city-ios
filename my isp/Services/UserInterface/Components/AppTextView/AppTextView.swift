import UIKit
import Combine

class AppTextView: UITextView {
    
    private let customDelegate: AppTextViewDelegateProtocol
    private var rootSubscriptions: Set<AnyCancellable>
    
    init(delegate: AppTextViewDelegateProtocol) {
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
        customDelegate.textExternalPublisher.sink { [weak self] in
            self?.delegateEvent($0)
        }.store(in: &rootSubscriptions)
    }
    
    func delegateEvent(_ event: AppTextViewDelegateEvent) {}
    
}
