import UIKit
import Combine

class AuthorizationPhoneRootViewController: UIViewController {
    
    private let viewModel: AuthorizationPhoneRootViewModelProtocol
    private let customView: AuthorizationPhoneRootViewProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(viewModel: AuthorizationPhoneRootViewModelProtocol, view: AuthorizationPhoneRootViewProtocol) {
        self.viewModel =  viewModel
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.internalEventPublisher.send(.setupNavigationBar)
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
