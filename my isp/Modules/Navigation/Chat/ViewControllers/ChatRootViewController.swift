import UIKit
import Combine

class ChatRootViewController: UIViewController {
    
    private let viewModel: ChatRootViewModelProtocol
    private let customView: ChatRootViewProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(viewModel: ChatRootViewModelProtocol, view: ChatRootViewProtocol) {
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
        viewModel.internalEventPublisher.send(.request(.data))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customView.setNeedsLayout()
        customView.layoutIfNeeded()
        viewModel.internalEventPublisher.send(.setupNavigationBar)
    }
    
    private func setupObservers() {
        viewModel.externalEventPublisher.sink { [weak self] in
            self?.customView.internalEventPublisher.send($0)
        }.store(in: &subscriptions)
        
        customView.externalEventPublisher.sink { [weak self] in
            self?.viewModel.internalEventPublisher.send(.request($0))
        }.store(in: &subscriptions)
    }
    
}
