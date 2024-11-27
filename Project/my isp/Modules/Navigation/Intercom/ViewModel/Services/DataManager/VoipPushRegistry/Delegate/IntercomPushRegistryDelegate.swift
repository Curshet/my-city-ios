import Foundation
import Combine
import PushKit

class IntercomPushRegistryDelegate: NSObject, IntercomPushRegistryDelegateProtocol {
    
    var publisher: AnyPublisher<PKPushCredentials, Never> {
        externalPublisher.eraseToAnyPublisher()
    }
    
    private let externalPublisher = PassthroughSubject<PKPushCredentials, Never>()

    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        externalPublisher.send(pushCredentials)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        completion()
    }

}
