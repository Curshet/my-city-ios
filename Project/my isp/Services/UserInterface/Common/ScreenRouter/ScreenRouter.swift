import UIKit

class ScreenRouter: NSObject {
    
    private weak var notificationsManager: AppNotificationsManagerPresentProtocol?
    private weak var displaySpinner: DisplaySpinnerProtocol?
    private let application: ApplicationProtocol
    private let mainQueue: DispatchQueue
    
    init(notificationsManager: AppNotificationsManagerPresentProtocol, displaySpinner: DisplaySpinnerProtocol, application: ApplicationProtocol) {
        self.notificationsManager = notificationsManager
        self.displaySpinner = displaySpinner
        self.application = application
        self.mainQueue = DispatchQueue.main
        super.init()
    }
    
}

// MARK: Private
private extension ScreenRouter {
    
    func push(source: UIViewController, target: UIViewController, animated: Bool, file: String, line: Int) {
        let navigationController: UINavigationController
        
        switch source as? UINavigationController {
            case .some(let viewController):
                navigationController = viewController
            
            case nil:
                guard let viewController = source.navigationController else {
                    logger.console(event: .error(info: String(source) + ScreenRouterMessage.navigationController), file: file, line: line)
                    return
                }
    
                navigationController = viewController
        }
    
        logger.console(event: .showScreen(info: ScreenRouterMessage.push + String(target)), file: file, line: line)
        navigationController.pushViewController(target, animated: animated)
    }
    
    func present(source: UIViewController, target: UIViewController, animated: Bool, completion: (() -> Void)?, file: String, line: Int) {
        logger.console(event: .showScreen(info: ScreenRouterMessage.present + String(target)), file: file, line: line)
        source.present(target, animated: animated, completion: completion)
    }
    
    func pop(source: UIViewController, target: RouterPopTransitionType, animated: Bool, file: String, line: Int) {
        let navigationController: UINavigationController
        
        switch source as? UINavigationController {
            case .some(let viewController):
                navigationController = viewController
            
            case nil:
                guard let viewController = source.navigationController else {
                    logger.console(event: .error(info: String(source) + ScreenRouterMessage.navigationController), file: file, line: line)
                    return
                }
    
                navigationController = viewController
        }
        
        logger.console(event: .closeScreen(info: ScreenRouterMessage.pop + String(source)), file: file, line: line)
        
        switch target {
            case .next:
                navigationController.popViewController(animated: animated)
            
            case .root:
                navigationController.popToRootViewController(animated: animated)
            
            case .target(let viewController):
                navigationController.popToViewController(viewController, animated: animated)
        }
    }
    
    func dismiss(viewController: UIViewController, animated: Bool, completion: (() -> Void)?, file: String, line: Int) {
        if let presentedViewController = viewController.presentedViewController {
            dismiss(presentedViewController, animated: animated)
        }
        
        logger.console(event: .closeScreen(info: ScreenRouterMessage.dismiss + String(viewController)), file: file, line: line)
        viewController.dismiss(animated: animated, completion: completion)
    }
    
    func animate(with duration: Double, delay: Double, damping: CGFloat, velocity: CGFloat, options: UIView.AnimationOptions, animation: @escaping () -> Void, completion: (() -> Void)?, file: String, line: Int) {

        UIView.animate(withDuration: duration, delay: delay, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: options) {
            self.logger.console(event: .any(info: ScreenRouterMessage.animationStart), file: file, line: line)
            animation()
        } completion: { _ in
            self.logger.console(event: .any(info: ScreenRouterMessage.animationFinish), file: file, line: line)
            completion?()
        }
    }
    
}

// MARK: Public
extension ScreenRouter {
    
    func userNotification(_ type: AppUserNotificationType) {
        notificationsManager?.presentUserNotification(type)
    }
    
    func displaySpinner(_ event: DisplaySpinnerEvent) {
        displaySpinner?.internalEventPublisher.send(event)
    }
    
    func open(path: String, completion: ((Bool) -> Void)? = nil, file: String = #file, line: Int = #line) {
        application.open(path: path, completion: completion, file: file, line: line)
    }
    
    func push(in source: UIViewController, the target: UIViewController, animated: Bool = true, file: String = #file, line: Int = #line) {
        mainQueue.asynchronous { [weak self] in
            self?.push(source: source, target: target, animated: animated, file: file, line: line)
        }
    }
    
    func present(in source: UIViewController, the target: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, file: String = #file, line: Int = #line) {
        mainQueue.asynchronous { [weak self] in
            self?.present(source: source, target: target, animated: animated, completion: completion, file: file, line: line)
        }
    }
    
    func pop(in source: UIViewController, the target: RouterPopTransitionType, animated: Bool = true, file: String = #file, line: Int = #line) {
        mainQueue.asynchronous { [weak self] in
            self?.pop(source: source, target: target, animated: animated, file: file, line: line)
        }
    }
    
    func dismiss(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil, file: String = #file, line: Int = #line) {
        mainQueue.asynchronous { [weak self] in
            self?.dismiss(viewController: viewController, animated: animated, completion: completion, file: file, line: line)
        }
    }
    
    func animate(duration: Double, delay: Double = .zero, damping: CGFloat = 1, velocity: CGFloat = 1, options: UIView.AnimationOptions = [], animation: @escaping () -> Void, completion: (() -> Void)? = nil, file: String = #file, line: Int = #line) {
        mainQueue.asynchronous { [weak self] in
            self?.animate(with: duration, delay: delay, damping: damping, velocity: velocity, options: options, animation: animation, completion: completion, file: file, line: line)
        }
    }
    
}

// MARK: - ScreenRouterMessage
fileprivate enum ScreenRouterMessage {
    static let push = "Push a view controller: "
    static let present = "Present a view controller: "
    static let pop = "Close a popped view controller: "
    static let dismiss = "Dismiss a view controller: "
    static let animationStart = "Animated routing process starts"
    static let animationFinish = "Animated routing process was completed"
    static let navigationController = " doesn't have a navigation controller for working with next view controller"
}

// MARK: - RouterPopTransitionType
enum RouterPopTransitionType {
    case next
    case root
    case target(UIViewController)
}
