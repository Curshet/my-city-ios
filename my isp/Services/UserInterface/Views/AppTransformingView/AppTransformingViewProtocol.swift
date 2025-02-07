import UIKit

protocol AppTransformingViewProtocol: UIView {
    func configureTransform(_ target: AppViewAnimationTarget)
    func transform(_ completion: (() -> Void)?)
}
