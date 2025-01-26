import UIKit

protocol AppCoordinatorProtocol {
    func start(_ options: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
}
