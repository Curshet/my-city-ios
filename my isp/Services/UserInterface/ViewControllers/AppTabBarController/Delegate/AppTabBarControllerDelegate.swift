import UIKit
import Combine

class AppTabBarControllerDelegate: NSObject, AppTabBarControllerDelegateProtocol {
    
    let publisher: AnyPublisher<AppTabBarControllerDelegateEvent, Never>
    let superExternalPublisher: PassthroughSubject<AppTabBarControllerDelegateEvent, Never>
    
    override init() {
        self.superExternalPublisher = PassthroughSubject<AppTabBarControllerDelegateEvent, Never>()
        self.publisher = AnyPublisher(superExternalPublisher)
        super.init()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        superExternalPublisher.send(.didSelect(viewController: viewController))
    }

    func tabBarController(_ tabBarController: UITabBarController, willBeginCustomizing viewControllers: [UIViewController]) {
        superExternalPublisher.send(.willBeginCustomizing(viewControllers: viewControllers))
    }

    func tabBarController(_ tabBarController: UITabBarController, willEndCustomizing viewControllers: [UIViewController], changed: Bool) {
        superExternalPublisher.send(.willEndCustomizing(viewControllers: viewControllers, changed: changed))
    }

    func tabBarController(_ tabBarController: UITabBarController, didEndCustomizing viewControllers: [UIViewController], changed: Bool) {
        superExternalPublisher.send(.didEndCustomizing(viewControllers: viewControllers, changed: changed))
    }
    
}

// MARK: - AppTabBarControllerDelegateEvent
enum AppTabBarControllerDelegateEvent {
    case shouldSelect(viewController: UIViewController)
    case didSelect(viewController: UIViewController)
    case willBeginCustomizing(viewControllers: [UIViewController])
    case willEndCustomizing(viewControllers: [UIViewController], changed: Bool)
    case didEndCustomizing(viewControllers: [UIViewController], changed: Bool)
    case supportedInterfaceOrientations
    case preferredInterfaceOrientationForPresentation
    case interactionControllerFor(animationController: UIViewControllerAnimatedTransitioning)
    case animationControllerForTransitionFrom(from: UIViewController, to: UIViewController)
}
