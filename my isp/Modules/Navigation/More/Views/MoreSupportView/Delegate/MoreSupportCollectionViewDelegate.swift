import UIKit

class MoreSupportCollectionViewDelegate: AppCollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10.fitWidth
    }
    
}
