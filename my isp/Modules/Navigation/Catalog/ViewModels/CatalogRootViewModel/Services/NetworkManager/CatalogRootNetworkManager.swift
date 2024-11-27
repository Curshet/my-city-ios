import Foundation
import Combine

class CatalogRootNetworkManager: NetworkManager, CatalogRootNetworkManagerProtocol {
    
    let internalEventPublisher: PassthroughSubject<CatalogRootNetworkInternalEvent, Never>
    let externalEventPublisher: AnyPublisher<Result<CatalogRootNetworkManagerResponse, CatalogRootNetworkManagerError>, Never>
    
    private let externalPublisher: PassthroughSubject<Result<CatalogRootNetworkManagerResponse, CatalogRootNetworkManagerError>, Never>
    private var subscriptions: Set<AnyCancellable>

    override init(decoder: JSONDecoderProtocol) {
        self.internalEventPublisher = PassthroughSubject<CatalogRootNetworkInternalEvent, Never>()
        self.externalPublisher = PassthroughSubject<Result<CatalogRootNetworkManagerResponse, CatalogRootNetworkManagerError>, Never>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init(decoder: decoder)
        setupObservers()
    }
    
}

// MARK: Private
private extension CatalogRootNetworkManager {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ type: CatalogRootNetworkInternalEvent) {
        switch type {
            case .systemInfo(let value):
                request(value.deviceInfo, completion: nil)
                request(value.firebaseInfo, completion: nil)
            
            case .firebaseInfo(let value):
                request(value, completion: nil)
        }
    }
    
}

// MARK: - CatalogRootNetworkInternalEvent
enum CatalogRootNetworkInternalEvent {
    case systemInfo(CatalogRootRequest)
    case firebaseInfo(NetworkManagerRequest)
}

// MARK: - CatalogRootNetworkManagerResponse
enum CatalogRootNetworkManagerResponse {
    case deviceInfo(Data)
    case firebaseInfo(Data)
}

// MARK: - CatalogRootNetworkManagerError
enum CatalogRootNetworkManagerError: Error {
    case deviceInfo(NSError)
    case firebaseInfo(NSError)
}
