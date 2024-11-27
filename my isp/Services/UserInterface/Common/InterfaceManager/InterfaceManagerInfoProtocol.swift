import UIKit
import Combine

protocol InterfaceManagerInfoProtocol {
    var publisher: AnyPublisher<UIUserInterfaceStyle, Never> { get }
    var information: InterfaceManagerDataProtocol { get }
}
