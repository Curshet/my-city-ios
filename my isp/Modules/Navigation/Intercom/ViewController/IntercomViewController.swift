import UIKit

class IntercomViewController: UIViewController {
    
    private weak var viewModel: IntercomViewModelProtocol?
    private let customView: IntercomViewProtocol
    
    init(viewModel: IntercomViewModelProtocol, view: IntercomViewProtocol) {
        self.viewModel = viewModel
        self.customView = view
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = customView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logger.console(event: .showScreen(info: typeName))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logger.console(event: .closeScreen(info: typeName))
    }
    
}
