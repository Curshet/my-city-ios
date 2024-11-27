import UIKit

protocol AppImageViewProtocol: UIImageView {
    func configureOverlay(_ layout: AppOverlayViewLayout)
    func startOverlay()
    func stopOverlay()
}
