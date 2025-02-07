import Foundation
import Combine
import PushKit

protocol IntercomPushRegistryDelegateProtocol: PKPushRegistryDelegate {
    var publisher: AnyPublisher<PKPushCredentials, Never> { get }
}
