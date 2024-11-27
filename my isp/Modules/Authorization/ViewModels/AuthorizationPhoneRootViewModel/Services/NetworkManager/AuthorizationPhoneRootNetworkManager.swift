import Foundation
import Combine

class AuthorizationPhoneRootNetworkManager: NetworkManager, AuthorizationPhoneRootNetworkManagerProtocol {
    
    let requestPublisher: PassthroughSubject<AuthorizationPhoneRootNetworkRequest, Never>
    let responsePublisher: AnyPublisher<Result<AuthorizationPhoneRootResponseData, NSError>, Never>
    
    private let externalPublisher: PassthroughSubject<Result<AuthorizationPhoneRootResponseData, NSError>, Never>
    private var subscriptions: Set<AnyCancellable>
    
    override init(decoder: JSONDecoderProtocol) {
        self.requestPublisher = PassthroughSubject<AuthorizationPhoneRootNetworkRequest, Never>()
        self.externalPublisher = PassthroughSubject<Result<AuthorizationPhoneRootResponseData, NSError>, Never>()
        self.responsePublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init(decoder: decoder)
        setupObservers()
    }
    
}

// MARK: Private
private extension AuthorizationPhoneRootNetworkManager {
    
    func setupObservers() {
        requestPublisher.sink { [weak self] in
            self?.getFirst($0)
        }.store(in: &subscriptions)
    }
    
    func getFirst(_ info: AuthorizationPhoneRootNetworkRequest) {
        request(info.getFirst, dataModel: AuthorizationPhoneRootNetworkData.self) { [weak self] in
            switch $0 {
                case .success(let data):
                    let timeInterval = Double(data?.smsTimeInterval ?? -1)
                    var output = info.output
                    output.timeInterval = timeInterval >= .zero ? timeInterval : output.timeInterval
                    self?.postPhone(info.postPhone, output)
                
                case .failure(let error):
                    self?.externalPublisher.send(.failure(error))
            }
        }
    }
    
    func postPhone(_ info: NetworkManagerRequest, _ data: AuthorizationPhoneRootResponseData) {
        request(info) { [weak self] in
            switch $0 {
                case .success:
                    self?.externalPublisher.send(.success(data))
                
                case .failure(let error):
                    self?.externalPublisher.send(.failure(error))
            }
        }
    }
    
}
