import Foundation
import Combine

class AuthorizationPhoneCodeNetworkManager: NetworkManager, AuthorizationPhoneCodeNetworkManagerProtocol {

    let requestPublisher: PassthroughSubject<NetworkManagerRequest, Never>
    let responsePublisher: AnyPublisher<Result<String, NSError>, Never>
    
    private let externalPublisher: PassthroughSubject<Result<String, NSError>, Never>
    private var subscriptions: Set<AnyCancellable>
    
    override init(decoder: JSONDecoderProtocol) {
        self.requestPublisher = PassthroughSubject<NetworkManagerRequest, Never>()
        self.externalPublisher = PassthroughSubject<Result<String, NSError>, Never>()
        self.responsePublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init(decoder: decoder)
        setupObservers()
    }
    
}

// MARK: Private
private extension AuthorizationPhoneCodeNetworkManager {
    
    func setupObservers() {
        requestPublisher.sink { [weak self] in
            self?.postCode($0)
        }.store(in: &subscriptions)
    }
    
    func postCode(_ info: NetworkManagerRequest) {
        request(info, dataModel: AuthorizationPhoneCodeNetworkData.self) { [weak self] in
            switch $0 {
                case .success(let data):
                    self?.dataHandler(data, info.path)
                
                case .failure(let error):
                    self?.externalPublisher.send(.failure(error))
            }
        }
    }
    
    func dataHandler(_ data: AuthorizationPhoneCodeNetworkData?, _ path: String) {
        guard let token = data?.token else {
            let error = NSError.dataFailure(domain: path)
            logger.console(event: .error(info: error))
            externalPublisher.send(.failure(error))
            return
        }

        externalPublisher.send(.success(token))
    }
    
}
