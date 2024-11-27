import Foundation
import Combine

protocol AppTimerProtocol: AnyObject {
    var publisher: AnyPublisher<AppTimeEvent, Never> { get }
    func start(seconds: Double, repeats: Bool, action: (() -> Void)?)
    func pause()
    func resume()
    func stop()
}
