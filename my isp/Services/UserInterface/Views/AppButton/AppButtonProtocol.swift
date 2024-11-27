import UIKit
import Combine

protocol AppButtonProtocol: UIButton {
    var publisher: AnyPublisher<UIControl.Event, Never> { get }
    func addTarget(_ value: UIControl.Event...)
    func removeTarget(_ value: UIControl.Event...)
    func setTouchInsets(_ value: CGPoint)
    func setTouchOffsets(_ value: CGPoint)
    func configureTransform(_ target: AppViewAnimationTarget)
    func configureOverlay(_ layout: AppOverlayViewLayout)
    func startOverlay()
    func stopOverlay()
}
