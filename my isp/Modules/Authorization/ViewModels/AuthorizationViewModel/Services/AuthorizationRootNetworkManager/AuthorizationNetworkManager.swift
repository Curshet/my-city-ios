import Foundation
import Combine

class AuthorizationNetworkManager: NetworkManager, AuthorizationNetworkManagerProtocol {
    
    let requestPublisher: PassthroughSubject<AuthorizationNetworkRequest, Never>
    let responsePublisher: AnyPublisher<Result<AuthorizationNetworkData, NSError>, Never>
    
    private let externalPublisher: PassthroughSubject<Result<AuthorizationNetworkData, NSError>, Never>
    private var subscriptions: Set<AnyCancellable>
    
    override init(decoder: JSONDecoderProtocol) {
        self.requestPublisher = PassthroughSubject<AuthorizationNetworkRequest, Never>()
        self.externalPublisher = PassthroughSubject<Result<AuthorizationNetworkData, NSError>, Never>()
        self.responsePublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init(decoder: decoder)
        setupObservers()
    }
    
}

// MARK: Private
extension AuthorizationNetworkManager {
    
    func setupObservers() {
        requestPublisher.sink { [weak self] in
            self?.postAuthorizationInfo($0)
        }.store(in: &subscriptions)
    }
    
    func postAuthorizationInfo(_ info: AuthorizationNetworkRequest) {
        request(info.value, dataModel: AuthorizationNetworkData.self) { [weak self] in
            switch $0 {
                case .success(var data):
                    data?.phone = info.phone
                    self?.dataHandler(data, info.value.path)
                
                case .failure(let error):
                    self?.externalPublisher.send(.failure(error))
            }
        }
    }

    func dataHandler(_ data: AuthorizationNetworkData?, _ path: String) {
        guard let data else {
            let error = NSError.dataFailure(domain: path)
            logger.console(event: .error(info: error))
            externalPublisher.send(.failure(error))
            return
        }
        
        externalPublisher.send(.success(data))
    }
    
}
