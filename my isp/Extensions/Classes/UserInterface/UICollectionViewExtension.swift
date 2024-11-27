import UIKit

extension UICollectionView {
    
    func registerCell<Cell: UICollectionViewCell>(type: Cell.Type) {
        register(type.self, forCellWithReuseIdentifier: type.typeName)
    }
    
}
