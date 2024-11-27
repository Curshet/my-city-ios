import Foundation
import Combine

protocol AppPresenterProtocol {
    var internalEventPublisher: PassthroughSubject<AppPresenterInternalEvent, Never> { get }
}
