import Foundation
import Combine

protocol LocalizationManagerInfoProtocol {
    var publisher: AnyPublisher<LocalizationManagerLanguage, Never> { get }
    var information: LocalizationManagerDataProtocol { get }
}
