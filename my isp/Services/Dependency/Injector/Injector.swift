import Foundation
import Swinject

final class Injector: NSObject, InjectorProtocol {

    private var containers: [InjectorContainerKey : Container]
    private let concurrentQueue: DispatchQueue
    
    override init() {
        self.containers = [InjectorContainerKey : Container]()
        self.concurrentQueue = DispatchQueue.create(label: "injector.workingProcess", qos: .userInitiated, attributes: .concurrent)
        super.init()
    }
    
    func register<Service>(in key: InjectorContainerKey, type: Service.Type, _ factory: @escaping (Resolver) -> Service) {
        concurrentQueue.async(flags: .barrier) { [weak self] in
            var container: Container? {
                self?.containers[key]
            }

            if container == nil {
                self?.containers[key] = Container()
            }
            
            container?.register(type, factory: factory)
        }
    }
    
    func resolve<Service>(from key: InjectorContainerKey, type: Service.Type) -> Service? {
        concurrentQueue.sync { [weak self] in
            self?.containers[key]?.resolve(Service.self)
        }
    }
    
    func remove(container key: InjectorContainerKey) {
        concurrentQueue.async(flags: .barrier) { [weak self] in
            guard let self, key != .application, containers[key] != nil else { return }
            containers[key] = nil
            logger.console(event: .any(info: "Dependencies container has been removed for the key: \(key)"))
        }
    }
    
}

// MARK: - InjectorContainerKey
enum InjectorContainerKey: Hashable {
    case application
    case authorization
    case navigation
}
