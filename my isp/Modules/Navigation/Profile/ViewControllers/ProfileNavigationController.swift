import UIKit

class ProfileNavigationController: AppNavigationController {
    
    private let viewModel: ProfileNavigationViewModelProtocol

    init(viewModel: ProfileNavigationViewModelProtocol, delegate: AppNavigationControllerDelegateProtocol, rootViewController: UIViewController) {
        self.viewModel = viewModel
        super.init(delegate: delegate, transitioningDelegate: nil, rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(toParent parent: UIViewController?) {
        viewModel.setupTabBarItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logger.console(event: .showScreen(info: "Show navigation menu \"Profile\" screen"))
    }
    
}
