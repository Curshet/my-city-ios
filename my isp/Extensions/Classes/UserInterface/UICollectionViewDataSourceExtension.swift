import UIKit

extension UICollectionViewDataSource {
    
    func defaultCell(_ collectionView: UICollectionView, _ indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: UICollectionViewCell.typeName, for: indexPath)
    }
    
}
