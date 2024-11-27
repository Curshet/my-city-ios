import UIKit
import Combine

final class DisplayViewController: UIViewController, DisplayViewControllerProtocol {
    
    let internalEventPublisher: PassthroughSubject<DisplaySpinnerEvent, Never>
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private let viewModel: DisplayViewModelProtocol
    private let customView: AppOverlayViewProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(viewModel: DisplayViewModelProtocol, view: AppOverlayViewProtocol) {
        self.viewModel = viewModel
        self.customView = view
        self.internalEventPublisher = PassthroughSubject<DisplaySpinnerEvent, Never>()
        self.subscriptions = Set<AnyCancellable>()
        super.init(nibName: nil, bundle: nil)
        setupObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(customView)
        viewModel.internalEventPublisher.send(.overlay)
    }
    
}

// MARK: Private
private extension DisplayViewController {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
        
        viewModel.externalEventPublisher.sink { [weak self] in
            self?.viewModelEventHandler($0)
        }.store(in: &subscriptions)
        
        customView.externalEventPublisher.sink { [weak self] in
            guard $0 == .stop else { return }
            self?.viewModel.internalEventPublisher.send(.overlay)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: DisplaySpinnerEvent) {
        guard case let .start(type) = event else {
            customView.internalEventPublisher.send(.animation(.inactive))
            return
        }
        
        switch type {
            case .layout(let value), .layoutWithKeyboard(let value):
                customView.internalEventPublisher.send(.layout(value))
            
            case .custom(let subview, let layout), .customWithKeyboard(let subview, let layout):
                viewModel.internalEventPublisher.send(.custom(layout))
                view.addSubview(subview)
            
            default:
                break
        }
        
        customView.internalEventPublisher.send(.animation(.active))
    }

    func viewModelEventHandler(_ event: DisplayViewModelExternalEvent) {
        switch event {
            case .custom(let layout):
                view.subviews.last?.removeFromSuperview()
                fallthrough
            
            case .overlay(let layout):
                customView.internalEventPublisher.send(.layout(layout))
        }
    }
    
}
