import UIKit
import Combine

class AppNavigationControllerDelegate: NSObject, AppNavigationControllerDelegateProtocol {
    
    let publisher: AnyPublisher<AppNavigationControllerDelegateEvent, Never>
    let superExternalPublisher: PassthroughSubject<AppNavigationControllerDelegateEvent, Never>
    
    override init() {
        self.superExternalPublisher = PassthroughSubject<AppNavigationControllerDelegateEvent, Never>()
        self.publisher = AnyPublisher(superExternalPublisher)
        super.init()
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        superExternalPublisher.send(.willShow(viewController: viewController, animated: animated))
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        superExternalPublisher.send(.didShow(viewController: viewController, animated: animated))
    }

}

// MARK: - AppNavigationControllerDelegateEvent
enum AppNavigationControllerDelegateEvent {
    case willShow(viewController: UIViewController, animated: Bool)
    case didShow(viewController: UIViewController, animated: Bool)
    case supportedInterfaceOrientations
    case preferredInterfaceOrientationForPresentation
    case interactionControllerFor(animationController: UIViewControllerAnimatedTransitioning)
    case animationControllerFor(operation: UINavigationController.Operation, from: UIViewController, to: UIViewController)
}
