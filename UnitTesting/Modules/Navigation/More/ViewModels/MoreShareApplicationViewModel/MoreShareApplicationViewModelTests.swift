import XCTest
import Combine
@testable import my_isp

final class MoreShareApplicationViewModelTests: XCTestCase {
    
    private var viewModel: MoreShareApplicationViewModel!
    private var viewController: UIActivityViewController!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        viewModel = MoreShareApplicationViewModel()
        viewController = UIActivityViewController(activityItems: viewModel.items, applicationActivities: nil)
    }

    override func tearDownWithError() throws {
        viewModel = nil
        viewController = nil
        try super.tearDownWithError()
    }

    func testItems() {
        let items = viewModel.items
        let metaData = items.first?.activityViewControllerLinkMetadata(viewController)
        let title = metaData?.title
        let text = items.first?.activityViewController(viewController, itemForActivityType: nil) as? String
        
        XCTAssertNotNil(metaData)
        XCTAssertNotNil(title)
        XCTAssertNotNil(text)

        XCTAssertFalse(items.isEmpty)
        XCTAssertFalse(title?.isEmpty ?? true)
        XCTAssertFalse(text?.isEmpty ?? true)
    }
    
}
