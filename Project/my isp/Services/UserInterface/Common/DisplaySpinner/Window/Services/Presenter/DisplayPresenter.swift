import UIKit
import Combine

final class DisplayPresenter: NSObject, DisplayPresenterProtocol {

    let internalEventPublisher: PassthroughSubject<DisplayPresenterInternalEvent, Never>
    
    private weak var window: UIWindow?
    private weak var dataSource: DisplayDataSourceWindowProtocol?
    private var subscriptions: Set<AnyCancellable>
    
    init(dataSource: DisplayDataSourceWindowProtocol) {
        self.dataSource = dataSource
        self.internalEventPublisher = PassthroughSubject<DisplayPresenterInternalEvent, Never>()
        self.subscriptions = Set<AnyCancellable>()
        super.init()
        startConfiguration()
    }

}

// MARK: Private
private extension DisplayPresenter {
    
    func startConfiguration() {
        setupObservers()
        setupConfiguration()
    }
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func setupConfiguration() {
        window?.alpha = .zero
        window?.isHidden = true
        window?.windowLevel = .alert
    }
    
    func internalEventHandler(_ event: DisplayPresenterInternalEvent) {
        if case .inject(let value) = event, window == nil {
            window = value
            window?.rootViewController?.loadViewIfNeeded()
            return
        }
        
        if event == .configure {
            setupLayout(dataSource?.layout)
        }
    }
    
    func setupLayout(_ value: DisplayWindowLayout?) {
        guard let value else {
            logger.console(event: .error(info: DisplayPresenterMessage.layout))
            return
        }
        
        guard let window else {
            logger.console(event: .error(info: DisplayPresenterMessage.window))
            return
        }
        
        guard window.isHidden else {
            hide(window, value)
            return
        }
        
        show(window, value)
    }
    
    func show(_ window: UIWindow, _ layout: DisplayWindowLayout) {
        UIView.animate(withDuration: layout.duration) {
            window.alpha = layout.alphaOne
        }
        
        window.isHidden = false
        logger.console(event: .showScreen(info: DisplayPresenterMessage.show))
    }
    
    func hide(_ window: UIWindow, _ layout: DisplayWindowLayout) {
        UIView.animate(withDuration: layout.duration) {
            window.alpha = layout.alphaTwo
        } completion: { _ in
            window.isHidden = true
            self.logger.console(event: .closeScreen(info: DisplayPresenterMessage.hide))
        }
    }
    
}

// MARK: - DisplayPresenterMessage
fileprivate enum DisplayPresenterMessage {
    static let layout = "Display spinner presenter doesn't have a layout value for configuration"
    static let window = "Display spinner presenter doesn't have a window for configuration"
    static let show = "Display spinner is showing"
    static let hide = "Display spinner was hidden"
}

// MARK: - DisplayPresenterInternalEvent
enum DisplayPresenterInternalEvent: Equatable {
    case inject(window: UIWindow)
    case configure
}
