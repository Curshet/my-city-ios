import UIKit
import Combine

class AppTabBarController: UITabBarController, AppTabBarControllerProtocol {
    
    let publisher: AnyPublisher<AppTabBarControllerDelegateEvent, Never>
    
    private let customDelegate: AppTabBarControllerDelegateProtocol
    private let customTransitioningDelegate: UIViewControllerTransitioningDelegate?
    
    init(delegate: AppTabBarControllerDelegateProtocol, transitioningDelegate: UIViewControllerTransitioningDelegate?) {
        self.customDelegate = delegate
        self.customTransitioningDelegate = transitioningDelegate
        self.publisher = customDelegate.publisher
        super.init(nibName: nil, bundle: nil)
        self.delegate = customDelegate
        self.transitioningDelegate = customTransitioningDelegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
