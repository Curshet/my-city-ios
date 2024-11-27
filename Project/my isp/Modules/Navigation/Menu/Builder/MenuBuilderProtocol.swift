import Foundation

protocol MenuBuilderProtocol {
    var coordinator: MenuCoordinatorProtocol? { get }
    var catalogCoordinator: CatalogCoordinatorProtocol? { get }
    var profileCoordinator: ProfileCoordinatorProtocol?  { get }
    var chatCoordinator: ChatCoordinatorProtocol? { get }
    var moreCoordinator: MoreCoordinatorProtocol? { get }
    var intercomCoordinator: IntercomCoordinatorProtocol? { get }
}
