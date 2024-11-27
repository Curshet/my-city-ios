import Foundation
import Combine

class ChatNavigationViewModel: ChatNavigationViewModelProtocol {
    
    private let presenter: AppearancePresenterProtocol
    private let dataSource: ChatNavigationDataSourceProtocol
    
    init(presenter: AppearancePresenterProtocol, dataSource: ChatNavigationDataSourceProtocol) {
        self.presenter = presenter
        self.dataSource = dataSource
    }
    
    func setupTabBarItem() {
        presenter.internalEvеntPublisher.send(.setup(.tabBarItem(dataSource.tabBarItem)))
    }
    
}
