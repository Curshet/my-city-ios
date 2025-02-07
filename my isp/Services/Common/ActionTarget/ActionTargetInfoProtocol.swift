import UIKit
import Combine

protocol ActionTargetInfoProtocol: ActionTargetFunctionProtocol {
    var publisher: AnyPublisher<UIControl.Event, Never> { get }
}
