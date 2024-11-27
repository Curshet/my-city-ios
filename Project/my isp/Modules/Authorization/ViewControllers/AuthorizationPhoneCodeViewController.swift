import UIKit
import Combine

class AuthorizationPhoneCodeViewController: AppModalViewController {
    
    private let viewModel: AuthorizationPhoneCodeViewModelProtocol
    private let customView: AppPhoneCodeViewProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(viewModel: AuthorizationPhoneCodeViewModelProtocol, view: AppPhoneCodeViewProtocol, background: UIVisualEffectView) {
        self.viewModel = viewModel
        self.customView = view
        self.subscriptions = Set<AnyCancellable>()
        super.init(foreground: customView, background: background)
        setupObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.internalEventPublisher.send(.dataRequest)
    }
    
    private func setupObservers() {
        viewModel.externalEventPublisher.sink { [weak self] in
            self?.customView.internalEventPublisher.send($0)
            guard case let .data(value) = $0 else { return }
            self?.setupBackground(value.background)
        }.store(in: &subscriptions)
        
        customView.externalEventPublisher.sink { [weak self] in
            self?.viewModel.internalEventPublisher.send(.select($0))
        }.store(in: &subscriptions)
    }
    
}
