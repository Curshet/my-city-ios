import UIKit
import Combine

protocol AppSwitchProtocol: UISwitch {
    var publisher: AnyPublisher<UIControl.Event, Never> { get }
    func addTarget(_ value: UIControl.Event...)
    func removeTarget(_ value: UIControl.Event...)
    func setTouchInsets(_ value: CGPoint)
    func setTouchOffsets(_ value: CGPoint)
    func configureOverlay(_ layout: AppOverlayViewLayout)
    func startOverlay()
    func stopOverlay()
}
