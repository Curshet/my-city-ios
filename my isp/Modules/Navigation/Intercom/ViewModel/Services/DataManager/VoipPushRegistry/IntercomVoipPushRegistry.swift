import Foundation
import Combine
import PushKit

class IntercomVoipPushRegistry: PKPushRegistry, IntercomVoipPushRegistryProtocol {
    
    let publisher: AnyPublisher<PKPushCredentials, Never>
    
    private let serialQueue: DispatchQueue
    private let customDelegate: IntercomPushRegistryDelegateProtocol
    
    init(delegate: IntercomPushRegistryDelegateProtocol) {
        self.serialQueue = DispatchQueue.create(label: "intercomVoipPushRegistry.receiveNotifications", qos: .userInteractive)
        self.customDelegate = delegate
        self.publisher = customDelegate.publisher
        super.init(queue: serialQueue)
        self.delegate = customDelegate
        self.desiredPushTypes = [.voIP]
    }
    
}
