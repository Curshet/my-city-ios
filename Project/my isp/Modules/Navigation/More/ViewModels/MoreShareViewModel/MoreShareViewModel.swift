import Foundation

class MoreShareViewModel: MoreShareViewModelProtocol {
    
    var items: [MoreShareActivityItem] {
        dataSource.items
    }
    
    private let dataSource: MoreShareDataSourceProtocol
    
    init(dataSource: MoreShareDataSourceProtocol) {
        self.dataSource = dataSource
    }
    
}
