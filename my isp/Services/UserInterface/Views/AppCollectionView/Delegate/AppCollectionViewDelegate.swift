import UIKit
import Combine

class AppCollectionViewDelegate: AppScrollViewDelegate, AppCollectionViewDelegateProtocol {
    
    let publisher: AnyPublisher<AppCollectionViewDelegateEventType, Never>
    let superExternalPublisher: PassthroughSubject<AppCollectionViewDelegateEventType, Never>
    
    private var subscriptions: Set<AnyCancellable>
    
    override init() {
        self.superExternalPublisher = PassthroughSubject<AppCollectionViewDelegateEventType, Never>()
        self.publisher = AnyPublisher(superExternalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init()
        setupObservers()
    }
    
    private func setupObservers() {
        publishеr.sink { [weak self] in
            self?.superExternalPublisher.send(.scrollViewDelegate($0))
        }.store(in: &subscriptions)
    }
    
}

// MARK: Protocol
extension AppCollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        superExternalPublisher.send(.collectionViewDelegate(.didHighlightItem(indexPath: indexPath)))
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        superExternalPublisher.send(.collectionViewDelegate(.didUnhighlightItem(indexPath: indexPath)))
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        superExternalPublisher.send(.collectionViewDelegate(.didSelectItem(indexPath: indexPath)))
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        superExternalPublisher.send(.collectionViewDelegate(.didDeselectItem(indexPath: indexPath)))
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        superExternalPublisher.send(.collectionViewDelegate(.willDisplay(indexPath: indexPath)))
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        superExternalPublisher.send(.collectionViewDelegate(.didEndDisplaying(indexPath: indexPath)))
    }

    func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        superExternalPublisher.send(.collectionViewDelegate(.didBeginMultipleSelectionInteraction(indexPath: indexPath)))
    }

    func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {
        superExternalPublisher.send(.collectionViewDelegate(.endMultipleSelection))
    }

}

// MARK: - AppCollectionViewDelegateEvent
enum AppCollectionViewDelegateEvent {
    case shouldHighlightItem(indexPath: IndexPath)
    case shouldUpdateFocus(context: UICollectionViewFocusUpdateContext)
    case shouldSpringLoadItem(indexPath: IndexPath, context: UISpringLoadedInteractionContext)
    case shouldSelectItem(indexPath: IndexPath)
    case shouldDeselectItem(indexPath: IndexPath)
    case shouldBeginMultipleSelectionInteraction(indexPath: IndexPath)
    case didHighlightItem(indexPath: IndexPath)
    case didUnhighlightItem(indexPath: IndexPath)
    case didSelectItem(indexPath: IndexPath)
    case didDeselectItem(indexPath: IndexPath)
    case didUpdateFocus(context: UICollectionViewFocusUpdateContext, coordinator: UIFocusAnimationCoordinator)
    case didBeginMultipleSelectionInteraction(indexPath: IndexPath)
    case willDisplay(indexPath: IndexPath)
    case didEndDisplaying(indexPath: IndexPath)
    case endMultipleSelection
    case canFocusItemindexPath(indexPath: IndexPath)
    case transitionLayout(from: UICollectionViewLayout, to: UICollectionViewLayout)
    case indexPathForPreferredFocusedView
    case proposedContentOffset(offset: CGPoint)
    case willPerformPreviewActionForMenu(configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating)
}

// MARK: - AppCollectionViewDelegateEventType
enum AppCollectionViewDelegateEventType {
    case collectionViewDelegate(AppCollectionViewDelegateEvent)
    case scrollViewDelegate(AppScrollViewDelegateEvent)
}
