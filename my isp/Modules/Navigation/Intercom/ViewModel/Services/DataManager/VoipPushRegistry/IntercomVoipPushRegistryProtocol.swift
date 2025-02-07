import Foundation
import PushKit
import Combine

protocol IntercomVoipPushRegistryProtocol {
    var publisher: AnyPublisher<PKPushCredentials, Never> { get }
}
