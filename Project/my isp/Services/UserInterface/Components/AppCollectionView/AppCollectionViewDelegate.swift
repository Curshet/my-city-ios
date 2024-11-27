import UIKit
import Combine

class AppCollectionViewDelegate: AppScrollViewDelegate, AppCollectionViewDelegateProtocol {
    
    var collectionExternalPublisher: AnyPublisher<AppCollectionViewDelegateEventType, Never> {
        collectionInternalPublisher.eraseToAnyPublisher()
    }
    
    let collectionInternalPublisher: PassthroughSubject<AppCollectionViewDelegateEventType, Never>
    
    private var rootSubscriptions: Set<AnyCancellable>
    
    override init() {
        self.collectionInternalPublisher = PassthroughSubject<AppCollectionViewDelegateEventType, Never>()
        self.rootSubscriptions = Set<AnyCancellable>()
        super.init()
        setupObservers()
    }
    
    private func setupObservers() {
        scrollExternalPublisher.sink { [weak self] in
            self?.collectionInternalPublisher.send(.scrollViewDelegate($0))
        }.store(in: &rootSubscriptions)
    }
    
}

// MARK: UICollectionViewDelegate
extension AppCollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        collectionInternalPublisher.send(.collectionViewDelegate(.didHighlightItem(indexPath: indexPath)))
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        collectionInternalPublisher.send(.collectionViewDelegate(.didUnhighlightItem(indexPath: indexPath)))
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionInternalPublisher.send(.collectionViewDelegate(.didSelectItem(indexPath: indexPath)))
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionInternalPublisher.send(.collectionViewDelegate(.didDeselectItem(indexPath: indexPath)))
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        collectionInternalPublisher.send(.collectionViewDelegate(.willDisplay(indexPath: indexPath)))
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        collectionInternalPublisher.send(.collectionViewDelegate(.didEndDisplaying(indexPath: indexPath)))
    }

    func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        collectionInternalPublisher.send(.collectionViewDelegate(.didBeginMultipleSelectionInteraction(indexPath: indexPath)))
    }

    func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {
        collectionInternalPublisher.send(.collectionViewDelegate(.endMultipleSelection))
    }

}

// MARK: AppCollectionViewDelegateEvent
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

// MARK: AppCollectionViewDelegateEventType
enum AppCollectionViewDelegateEventType{
    case collectionViewDelegate(AppCollectionViewDelegateEvent)
    case scrollViewDelegate(AppScrollViewDelegateEvent)
}

// MARK: AppCollectionViewDelegateProtocol
protocol AppCollectionViewDelegateProtocol: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    var collectionExternalPublisher: AnyPublisher<AppCollectionViewDelegateEventType, Never> { get }
}
