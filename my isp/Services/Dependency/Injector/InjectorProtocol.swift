import Foundation
import Swinject

protocol InjectorProtocol {
    func register<Service>(in: InjectorContainerKey, type: Service.Type, _ factory: @escaping (Resolver) -> Service)
    func resolve<Service>(from: InjectorContainerKey, type: Service.Type) -> Service?
    func remove(container: InjectorContainerKey)
}
