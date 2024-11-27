import UIKit
import Combine

protocol ProfileRootCenterUserInfoSectionViewProtocol: UIView {
    var internalEventPublisher: PassthroughSubject<ProfileRootCenterUserInfoSectionData, Never> { get }
    var externalEventPublisher: AnyPublisher<String?, Never> { get }
}
