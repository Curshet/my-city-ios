import Foundation
import Combine

class ProfileRootNetworkManager: NetworkManager, ProfileRootNetworkManagerProtocol {
    
    let internalEventPublisher: PassthroughSubject<Void, Never>
    let externalEventPublisher: AnyPublisher<Decodable, NSError>
    
    private let externalPublisher: PassthroughSubject<Decodable, NSError>
    private var subscriptions: Set<AnyCancellable>
    
    override init(decoder: JSONDecoderProtocol) {
        self.internalEventPublisher = PassthroughSubject<Void, Never>()
        self.externalPublisher = PassthroughSubject<Decodable, NSError>()
        self.externalEventPublisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init(decoder: decoder)
    }
    
}
