import UIKit
import Combine

class CatalogRootViewController: UIViewController {
    
    private let viewModel: CatalogRootViewModelProtocol
    private let customView: CatalogRootCollectionViewProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(viewModel: CatalogRootViewModelProtocol, view: CatalogRootCollectionViewProtocol) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.internalEventPublisher.send(.setupNavigationBar)
    }
    
    private func setupObservers() {
        viewModel.externalEventPublisher.sink { [weak self] in
            self?.customView.dataPublisher.send($0)
        }.store(in: &subscriptions)
    }
    
}
