import Foundation
import Combine

protocol KeyboardManagerProtocol {
    var publisher: AnyPublisher<KeyboardManagerEvent, Never> { get }
}
