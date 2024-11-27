import Foundation
import Combine

protocol DisplayPresenterProtocol {
    var internalEventPublisher: PassthroughSubject<DisplayPresenterInternalEvent, Never> { get }
}
