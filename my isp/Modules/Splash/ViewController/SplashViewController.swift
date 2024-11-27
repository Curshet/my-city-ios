import UIKit
import Combine

class SplashViewController: UIViewController {
    
    override var prefersStatusBarHidden: Bool {
        true
    }
    
    private let viewModel: SplashViewModelProtocol
    private let customView: SplashViewProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(viewModel: SplashViewModelProtocol, view: SplashViewProtocol) {
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
        logger.console(event: .showScreen(info: "Show application \"Splash\" screen"))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        logger.console(event: .closeScreen(info: "Close application \"Splash\" screen"))
    }
    
    private func setupObservers() {
        viewModel.externalEventPublisher.sink { [weak self] in
            self?.customView.internalEventPublisher.send($0)
        }.store(in: &subscriptions)
        
        customView.externalEventPublisher.sink { [weak self] in
            self?.viewModel.internalEventPublisher.send(.exit)
        }.store(in: &subscriptions)
    }
    
}
