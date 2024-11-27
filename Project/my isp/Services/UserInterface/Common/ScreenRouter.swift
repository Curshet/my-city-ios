import UIKit

@MainActor
final class ScreenRouter {

    /// Screen navigation. Do not forget to use main thread!
    static func transition(_ type: RouterTransitionType, isAnimated: Bool = true, file: String = #file, line: Int = #line) {
        let logger = LoggingManager.entry
        
        switch type {
            case.push(let source, let target):
                guard let navigationController = source.navigationController else {
                    logger.console(event: .error(info: "View controller: \(source) doesn't have navigation controller for pushing: \(target)"), file: file, line: line)
                    return
                }

                navigationController.pushViewController(target, animated: isAnimated)
                logger.console(event: .showScreen(info: "Pushing to view controller: \(target)"), file: file, line: line)
            
            case .present(let source, let target):
                switch target {
                    case .controller(let viewController):
                        source.present(viewController, animated: isAnimated)
                        logger.console(event: .showScreen(info: "Presenting view controller: \(viewController)"), file: file, line: line)
                    
                    case .alert(let style, let title, let message, let type):
                        let alertController = UIAlertController.create(style: style, title: title, message: message, type: type)
                        source.present(alertController, animated: isAnimated)
                        logger.console(event: .showScreen(info: "Presenting alert controller: \(alertController)"), file: file, line: line)
                }
            
            case .pop(let viewController):
                guard let navigationController = viewController.navigationController else {
                    logger.console(event: .error(info: "View controller: \(viewController) doesn't have navigation controller for showing popped view controller"), file: file, line: line)
                    return
                }
            
                navigationController.popViewController(animated: isAnimated)
                logger.console(event: .closeScreen(info: "Closing popped view controller: \(viewController)"), file: file, line: line)
            
            case .dismiss(let viewController):
                viewController.dismiss(animated: isAnimated)
                logger.console(event: .closeScreen(info: "Dismissing view controller: \(viewController)"), file: file, line: line)
        }
    }
    
    private init() {}
    
}

// MARK: RouterTransitionType
enum RouterTransitionType {
    case push(from: UIViewController, the: UIViewController)
    case present(from: UIViewController, the: RouterPresentingType)
    case pop(UIViewController)
    case dismiss(UIViewController)
}

// MARK: RouterPresentingType
enum RouterPresentingType {
    case controller(UIViewController)
    case alert(style: UIAlertController.Style, title: String, message: String, type: AlertControllerType)
}
