import Foundation
import Network
import Combine

protocol ConnectionManagerProtocol {
    var publisher: AnyPublisher<(isConnected: Bool, connectionType: NWInterface.InterfaceType?), Never> { get }
    var information: ConnectionManagerDataProtocol { get }
}
