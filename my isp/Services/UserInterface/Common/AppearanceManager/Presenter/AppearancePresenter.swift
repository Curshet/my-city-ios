import UIKit
import Combine

class AppearancePresenter: NSObject, AppearancePresenterProtocol {

    let internalEvеntPublisher: PassthroughSubject<AppearancePresenterInternalEvent, Never>

    private weak var viewController: UIViewController?
    private var subscriptions: Set<AnyCancellable>
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
        self.internalEvеntPublisher = PassthroughSubject<AppearancePresenterInternalEvent, Never>()
        self.subscriptions = Set<AnyCancellable>()
        super.init()
        setupObservers()
    }
    
    convenience override init() {
        self.init(viewController: nil)
        setupObservers()
    }
    
    func setupAppearance(_ target: AppearanceTarget) {
        switch target {
            case .navigationBar(let appearance):
                setupNavigationBar(appearance)
            
            case .tabBarItem(let value):
                viewController?.tabBarItem = value
        }
    }
    
}

// MARK: Private
private extension AppearancePresenter {
    
    func setupObservers() {
        internalEvеntPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: AppearancePresenterInternalEvent) {
        switch event {
            case .inject(let value):
                guard viewController == nil else { return }
                viewController = value

            case .setup(let target):
                setupTarget(target)
        }
    }
    
    func setupTarget(_ target: AppearanceTarget) {
        guard viewController != nil else {
            logger.console(event: .error(info: AppearancePresenterMessage.viewControllerError))
            return
        }
        
        switch target {
            case .navigationBar:
                guard isNavigationControllerExist() else { return }
            
            case .tabBarItem:
                guard isTabBarControllerExist() else { return }
        }

        DispatchQueue.main.asynchronous { [weak self] in
            self?.setupAppearance(target)
        }
    }
    
    func isNavigationControllerExist() -> Bool {
        guard viewController?.navigationController != nil else {
            logger.console(event: .error(info: AppearancePresenterMessage.navigationControllerError))
            return false
        }
        
        return true
    }
    
    func isTabBarControllerExist() -> Bool {
        guard viewController?.tabBarController != nil else {
            logger.console(event: .error(info: AppearancePresenterMessage.tabBarControllerError))
            return false
        }
        
        return true
    }
    
    func setupNavigationBar(_ appearance: NavigationBarAppearance) {
        viewController?.title = appearance.model.title
        viewController?.navigationItem.backBarButtonItem = appearance.model.backBarButtonItem
        viewController?.navigationItem.rightBarButtonItem = appearance.model.rightBarButtonItem
        viewController?.navigationController?.navigationBar.isUserInteractionEnabled = appearance.model.interactive
        viewController?.navigationController?.navigationBar.standardAppearance = appearance.standard
        viewController?.navigationController?.navigationBar.compactAppearance = appearance.compact
        viewController?.navigationController?.navigationBar.scrollEdgeAppearance = appearance.scrollEdge
    }
    
}

// MARK: Protocol
extension AppearancePresenter {
    
    var information: AppearancePresenterData {
        let viewLoaded = viewController?.isViewLoaded ?? false
        let safeArea = viewLoaded ? viewController?.view.safeAreaLayoutGuide : nil
        let navigationBar = viewController?.navigationController?.navigationBar.frame ?? .zero
        let information = AppearancePresenterData(viewLoaded: viewLoaded, safeArea: safeArea, navigationBar: navigationBar)
        return information
    }
    
}

// MARK: - AppearancePresenterMessage
fileprivate enum AppearancePresenterMessage {
    static let viewControllerError = "Appearance presenter doesn't have a view controller"
    static let navigationControllerError = "Appearance presenter view controller doesn't have a navigation controller"
    static let tabBarControllerError = "Appearance presenter view controller doesn't have a tab bar controller"
}

// MARK: - AppearancePresenterData
struct AppearancePresenterData {
    let viewLoaded: Bool
    let safeArea: UILayoutGuide?
    let navigationBar: CGRect
}

// MARK: - AppearancePresenterInternalEvent
enum AppearancePresenterInternalEvent {
    case inject(viewController: UIViewController)
    case setup(AppearanceTarget)
}

// MARK: - AppearanceTarget
enum AppearanceTarget {
    case navigationBar(NavigationBarAppearance)
    case tabBarItem(UITabBarItem)
}

// MARK: - NavigationBarAppearance
struct NavigationBarAppearance {
    let model: NavigationBarAppearanceModel
    let standard: UINavigationBarAppearance
    let compact: UINavigationBarAppearance?
    let scrollEdge: UINavigationBarAppearance?
}

// MARK: - NavigationBarAppearanceModel
struct NavigationBarAppearanceModel {
    var title: String? = nil
    var backBarButtonItem: UIBarButtonItem? = nil
    var rightBarButtonItem: UIBarButtonItem? = nil
    var interactive = true
}
