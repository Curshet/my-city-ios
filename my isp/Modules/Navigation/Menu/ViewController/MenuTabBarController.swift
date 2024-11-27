import UIKit

class MenuTabBarController: AppTabBarController {
    
    private let viewModel: MenuViewModelProtocol
    
    init(viewModel: MenuViewModelProtocol, delegate: AppTabBarControllerDelegateProtocol) {
        self.viewModel = viewModel
        super.init(delegate: delegate, transitioningDelegate: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        logger.console(event: .showScreen(info: "Show application navigation menu"))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        logger.console(event: .closeScreen(info: "Close application navigation menu"))
    }
    
}
