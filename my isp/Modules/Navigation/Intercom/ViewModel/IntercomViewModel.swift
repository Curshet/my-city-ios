import Foundation
import Combine

class IntercomViewModel: IntercomViewModelProtocol {
    
    private weak var router: IntercomRouterProtocol?
    private let dataManager: IntercomDataManagerProtocol
    private var subscriptions: Set<AnyCancellable>
    
    init(router: IntercomRouterProtocol, dataManager: IntercomDataManagerProtocol) {
        self.router = router
        self.dataManager = dataManager
        self.subscriptions = Set<AnyCancellable>()
    }
    
}
