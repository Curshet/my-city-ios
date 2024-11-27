import UIKit

class MoreRootCollectionViewDelegate: AppCollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private weak var dataCache: MoreRootDataCacheSizesProtocol?
    
    init(dataCache: MoreRootDataCacheSizesProtocol?) {
        self.dataCache = dataCache
        super.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        dataCache?.sizes?[indexPath.row] ?? .zero
    }
    
}
