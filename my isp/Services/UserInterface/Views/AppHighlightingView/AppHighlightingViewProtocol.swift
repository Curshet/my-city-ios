import UIKit

protocol AppHighlightingViewProtocol: UIView {
    func backgroundColor(_ value: UIColor?)
    func configureTransform(_ target: AppViewAnimationTarget)
    func configureHighlight(_ target: AppViewAnimationTarget)
    func highlight(_ completion: (() -> Void)?)
}
