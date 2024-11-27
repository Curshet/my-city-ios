import Foundation
import Network
import Combine

final class ConnectionManager: NSObject, ConnectionManagerProtocol {
    
    static let entry = ConnectionManager()
    
    /// Network connection status publisher
    let publisher: AnyPublisher<(isConnected: Bool, connectionType: NWInterface.InterfaceType?), Never>
    
    /// Network connection information
    let information: ConnectionManagerDataProtocol
    
    fileprivate var data: (isConnected: Bool?, connectionType: NWInterface.InterfaceType?)
    
    private let decoder: JSONDecoderProtocol
    private let networkManager: NetworkManager
    private let monitor: NWPathMonitor
    private let serialQueue: DispatchQueue
    private let types: [NWInterface.InterfaceType]
    private let externalPublisher: PassthroughSubject<(isConnected: Bool, connectionType: NWInterface.InterfaceType?), Never>
    
    private override init() {
        self.decoder = JSONDecoder()
        self.networkManager = NetworkManager(decoder: decoder)
        self.monitor = NWPathMonitor()
        self.serialQueue = DispatchQueue.create(label: "connectionManager.networkMonitoring", qos: .userInitiated)
        self.types = [.wifi, .cellular, .wiredEthernet, .loopback, .other]
        self.externalPublisher = PassthroughSubject<(isConnected: Bool, connectionType: NWInterface.InterfaceType?), Never>()
        self.publisher = AnyPublisher(externalPublisher)
        self.information = ConnectionManagerData()
        super.init()
        start()
    }
    
}

// MARK: Private
private extension ConnectionManager {
    
    func start() {
        monitor.start(queue: serialQueue)
        
        monitor.pathUpdateHandler = {
            self.pathUpdateHandler($0)
        }
        
        logger.console(event: .any(info: "Network connection status monitoring started"))
    }
    
    func pathUpdateHandler(_ info: NWPath) {
        let isConnected = info.status != .unsatisfied
        let connectionType = self.types.filter { info.usesInterfaceType($0) }.first
        
        guard isConnected else {
            self.logger.console(event: .error(info: "Network connection status: \(isConnected), connection type: \(String(connectionType))"))
            self.data = (isConnected: isConnected, connectionType: connectionType)
            self.externalPublisher.send((isConnected: isConnected, connectionType: connectionType))
            return
        }

        let request = NetworkManagerRequest(type: .get, path: URL.Server.production, headers: .empty, parameters: .empty, queue: serialQueue)
        
        networkManager.request(request, errorHandling: false) {
            self.responseHandler($0, connectionType)
        }
    }
    
    func responseHandler(_ result: Result<Data?, NSError>, _ connectionType: NWInterface.InterfaceType?) {
        let isConnected: Bool
        
        switch result {
            case .success:
                isConnected = true
                logger.console(event: .success(info: "Network connection status: \(isConnected), connection type: \(String(connectionType))"))
            
            case .failure:
                isConnected = false
                logger.console(event: .error(info: "Network connection status: \(isConnected), connection type: \(String(connectionType))"))
        }
        
        data = (isConnected: isConnected, connectionType: connectionType)
        externalPublisher.send((isConnected: isConnected, connectionType: connectionType))
    }
    
}

// MARK: - ConnectionManagerData
fileprivate struct ConnectionManagerData: ConnectionManagerDataProtocol {
    var isConnected: Bool? {
        ConnectionManager.entry.data.isConnected
    }
    
    var connectionType: NWInterface.InterfaceType? {
        ConnectionManager.entry.data.connectionType
    }
}

// MARK: - ConnectionManagerDataProtocol
protocol ConnectionManagerDataProtocol {
    var isConnected: Bool? { get }
    var connectionType: NWInterface.InterfaceType? { get }
}
