import UIKit
import Combine

class AppScrollViewDelegate: NSObject, AppScrollViewDelegateProtocol {

    let publishеr: AnyPublisher<AppScrollViewDelegateEvent, Never>
    let superExtеrnalPublishеr: PassthroughSubject<AppScrollViewDelegateEvent, Never>
    
    override init() {
        self.superExtеrnalPublishеr = PassthroughSubject<AppScrollViewDelegateEvent, Never>()
        self.publishеr = AnyPublisher(superExtеrnalPublishеr)
        super.init()
    }
    
}

// MARK: Protocol
extension AppScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        superExtеrnalPublishеr.send(.didScroll)
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        superExtеrnalPublishеr.send(.didScrollToTop)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        superExtеrnalPublishеr.send(.didEndScrollingAnimation)
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        superExtеrnalPublishеr.send(.didChangeAdjustedContentInset)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        superExtеrnalPublishеr.send(.willBeginDragging)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        superExtеrnalPublishеr.send(.willEndDragging(velocity: velocity, targetContentOffset: targetContentOffset))
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        superExtеrnalPublishеr.send(.didEndDragging(isDecelerate: decelerate))
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        superExtеrnalPublishеr.send(.willBeginDecelerating)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        superExtеrnalPublishеr.send(.didEndDecelerating)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        superExtеrnalPublishеr.send(.willBeginZooming(view: view))
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        superExtеrnalPublishеr.send(.didEndZooming(view: view, scale: scale))
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        superExtеrnalPublishеr.send(.didZoom)
    }
    
}

// MARK: - AppScrollViewDelegateEvent
enum AppScrollViewDelegateEvent: Equatable {
    case shouldScrollToTop
    case didScroll
    case didScrollToTop
    case didEndScrollingAnimation
    case didChangeAdjustedContentInset
    case willBeginDragging
    case beginDragging
    case willEndDragging(velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    case didEndDragging(isDecelerate: Bool)
    case willBeginDecelerating
    case didEndDecelerating
    case viewForZooming
    case willBeginZooming(view: UIView?)
    case didEndZooming(view: UIView?, scale: CGFloat)
    case didZoom
}
