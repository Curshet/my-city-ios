import Foundation

class ProfileNavigationViewModel: ProfileNavigationViewModelProtocol {
    
    private let presenter: AppearancePresenterProtocol
    private let dataSource: ProfileNavigationDataSourceProtocol
    
    init(presenter: AppearancePresenterProtocol, dataSource: ProfileNavigationDataSourceProtocol) {
        self.presenter = presenter
        self.dataSource = dataSource
    }
    
    func setupTabBarItem() {
        presenter.internalEvеntPublisher.send(.setup(.tabBarItem(dataSource.tabBarItem)))
    }
    
}
