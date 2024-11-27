import UIKit
import Combine

class AppNavigationController: UINavigationController, AppNavigationControllerProtocol {

    let publisher: AnyPublisher<AppNavigationControllerDelegateEvent, Never>
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private let customDelegate: AppNavigationControllerDelegateProtocol
    private let customTransitioningDelegate: UIViewControllerTransitioningDelegate?
    
    init(delegate: AppNavigationControllerDelegateProtocol, transitioningDelegate: UIViewControllerTransitioningDelegate?, rootViewController: UIViewController) {
        self.customDelegate = delegate
        self.customTransitioningDelegate = transitioningDelegate
        self.publisher = customDelegate.publisher
        super.init(rootViewController: rootViewController)
        self.delegate = customDelegate
        self.transitioningDelegate = customTransitioningDelegate
    }
    
    init(delegate: AppNavigationControllerDelegate, transitioningDelegate: UIViewControllerTransitioningDelegate?) {
        self.customDelegate = delegate
        self.publisher = customDelegate.publisher
        self.customTransitioningDelegate = transitioningDelegate
        super.init(nibName: nil, bundle: nil)
        self.transitioningDelegate = customTransitioningDelegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
