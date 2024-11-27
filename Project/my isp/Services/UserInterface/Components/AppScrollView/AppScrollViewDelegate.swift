import UIKit
import Combine

class AppScrollViewDelegate: MetricProtocol, AppScrollViewDelegateProtocol {

    var scrollExternalPublisher: AnyPublisher<AppScrollViewDelegateEvent, Never> {
        scrollInternalPublisher.eraseToAnyPublisher()
    }
    
    let scrollInternalPublisher = PassthroughSubject<AppScrollViewDelegateEvent, Never>()
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollInternalPublisher.send(.didScroll)
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollInternalPublisher.send(.didScrollToTop)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollInternalPublisher.send(.didEndScrollingAnimation)
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        scrollInternalPublisher.send(.didChangeAdjustedContentInset)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollInternalPublisher.send(.willBeginDragging)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollInternalPublisher.send(.willEndDragging(velocity: velocity, targetContentOffset: targetContentOffset))
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollInternalPublisher.send(.didEndDragging(isDecelerate: decelerate))
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollInternalPublisher.send(.willBeginDecelerating)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollInternalPublisher.send(.didEndDecelerating)
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollInternalPublisher.send(.willBeginZooming(view: view))
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollInternalPublisher.send(.didEndZooming(view: view, scale: scale))
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollInternalPublisher.send(.didZoom)
    }
    
}

// MARK: AppScrollViewDelegateEvent
enum AppScrollViewDelegateEvent {
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

// MARK: AppScrollViewDelegateProtocol
protocol AppScrollViewDelegateProtocol: UIScrollViewDelegate {
    var scrollExternalPublisher: AnyPublisher<AppScrollViewDelegateEvent, Never> { get }
}
