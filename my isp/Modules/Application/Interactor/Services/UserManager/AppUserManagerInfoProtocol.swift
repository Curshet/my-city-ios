import Foundation
import Combine

protocol AppUserManagerInfoProtocol: AnyObject {
    var externalEventPublisher: AnyPublisher<AppUserManagerExternalEvent, Never> { get }
    func information(of: AppUserManagerInfoType...) -> AppUserInfo
}
