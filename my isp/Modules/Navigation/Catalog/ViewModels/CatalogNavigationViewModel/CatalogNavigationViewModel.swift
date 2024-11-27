import Foundation

class CatalogNavigationViewModel: CatalogNavigationViewModelProtocol {
    
    private let presenter: AppearancePresenterProtocol
    private let dataSource: CatalogNavigationDataSourceProtocol
    
    init(presenter: AppearancePresenterProtocol, dataSource: CatalogNavigationDataSourceProtocol) {
        self.presenter = presenter
        self.dataSource = dataSource
    }
    
    func setupTabBarItem() {
        presenter.internalEvеntPublisher.send(.setup(.tabBarItem(dataSource.tabBarItem)))
    }
    
}
