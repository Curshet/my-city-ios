import UIKit

class CatalogNavigationController: AppNavigationController {
    
    private let viewModel: CatalogNavigationViewModelProtocol

    init(viewModel: CatalogNavigationViewModelProtocol, delegate: AppNavigationControllerDelegateProtocol, rootViewController: UIViewController) {
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
        logger.console(event: .showScreen(info: "Show navigation menu \"Catalog\" screen"))
    }
    
}
