import UIKit
import Combine

class AuthorizationViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        viewModel.isLightMode ? .darkContent : .lightContent
    }
    
    private let viewModel: AuthorizationViewModelProtocol
    private let customView: AuthorizationViewProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(viewModel: AuthorizationViewModelProtocol, view: AuthorizationViewProtocol) {
        self.viewModel = viewModel
        self.customView = view
        self.subscriptions = Set<AnyCancellable>()
        super.init(nibName: nil, bundle: nil)
        setupObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.internalEventPublisher.send(.dataRequest)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logger.console(event: .showScreen(info: "Show application \"Authorization\" screen"))
    }
    
    private func setupObservers() {
        viewModel.externalEventPublisher.sink { [weak self] in
            self?.customView.internalEventPublisher.send($0)
        }.store(in: &subscriptions)
        
        customView.externalEventPublisher.sink { [weak self] in
            self?.viewModel.internalEventPublisher.send(.select($0))
        }.store(in: &subscriptions)
    }
    
}
