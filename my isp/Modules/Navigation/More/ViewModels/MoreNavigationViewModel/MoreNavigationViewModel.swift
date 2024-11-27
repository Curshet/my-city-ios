import Foundation
import Combine

class MoreNavigationViewModel: MoreNavigationViewModelProtocol {
    
    private let presenter: AppearancePresenterProtocol
    private let dataSource: MoreNavigationDataSourceProtocol
    
    init(presenter: AppearancePresenterProtocol, dataSource: MoreNavigationDataSourceProtocol) {
        self.presenter = presenter
        self.dataSource = dataSource
    }

    func setupTabBarItem() {
        presenter.internalEvеntPublisher.send(.setup(.tabBarItem(dataSource.tabBarItem)))
    }
    
}
