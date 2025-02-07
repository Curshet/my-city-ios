import UIKit

class AppViewController: UIViewController {
    
    private let customTransitioningDelegate: UIViewControllerTransitioningDelegate
    
    init(transitioningDelegate: UIViewControllerTransitioningDelegate) {
        self.customTransitioningDelegate = transitioningDelegate
        super.init(nibName: nil, bundle: nil)
        self.transitioningDelegate = customTransitioningDelegate
        self.modalPresentationStyle = .custom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
