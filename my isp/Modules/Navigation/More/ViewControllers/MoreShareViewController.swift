import UIKit

class MoreShareViewController: UIActivityViewController {
    
    private let viewModel: MoreShareViewModelProtocol
    
    init(viewModel: MoreShareViewModelProtocol) {
        self.viewModel = viewModel
        super.init(activityItems: viewModel.items, applicationActivities: nil)
        self.excludedActivityTypes = [.airDrop, .openInIBooks, .addToReadingList, .markupAsPDF, .postToFacebook, .postToTwitter, .print, .saveToCameraRoll, .assignToContact]
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logger.console(event: .closeScreen(info: typeName))
    }
    
}
