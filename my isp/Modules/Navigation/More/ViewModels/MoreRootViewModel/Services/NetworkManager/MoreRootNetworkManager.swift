import Foundation
import Combine

class MoreRootNetworkManager: NetworkManager, MoreRootNetworkManagerProtocol {

    let internalEventPublisher: PassthroughSubject<NetworkManagerRequest, Never>
    let externalEventPublisher: AnyPublisher<Result<MoreSupportContacts, NSError>, Never>
    
    private let externalPublisher: PassthroughSubject<Result<MoreSupportContacts, NSError>, Never>
    private var subscriptions: Set<AnyCancellable>
    
    override init(decoder: JSONDecoderProtocol) {
        self.internalEventPublisher = PassthroughSubject<NetworkManagerRequest, Never>()
        self.externalPublisher = PassthroughSubject<Result<MoreSupportContacts, NSError>, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init(decoder: decoder)
        setupObservers()
    }
    
}

// MARK: Private
private extension MoreRootNetworkManager {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ value: NetworkManagerRequest) {
        request(value, dataModel: MoreSupportContacts.self) { [weak self] in
            guard let response = self?.response($0, path: value.path) else { return }
            self?.externalPublisher.send(response)
        }
    }
    
}
