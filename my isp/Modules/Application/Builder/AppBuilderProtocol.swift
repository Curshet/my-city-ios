import UIKit

protocol AppBuilderProtocol {
    var module: AppBuilderModule? { get }
    var splashCoordinator: SplashCoordinatorProtocol? { get }
    var authorizationCoordinator: AuthorizationCoordinatorProtocol? { get }
    var navigationCoordinator: MenuCoordinatorProtocol? { get }
}
