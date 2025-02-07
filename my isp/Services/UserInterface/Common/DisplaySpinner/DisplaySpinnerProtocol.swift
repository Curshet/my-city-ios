import Foundation
import Combine

protocol DisplaySpinnerProtocol: AnyObject {
    var internalEventPublisher: PassthroughSubject<DisplaySpinnerEvent, Never> { get }
}
