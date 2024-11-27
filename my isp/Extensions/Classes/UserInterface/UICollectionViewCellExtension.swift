import UIKit

extension UICollectionViewCell {
    
    static func create<Cell: UICollectionViewCell>(type: Cell.Type, _ collectionView: UICollectionView, _ indexPath: IndexPath) -> Cell {
        collectionView.dequeueReusableCell(withReuseIdentifier: Cell.typeName, for: indexPath) as! Cell
    }
    
}
