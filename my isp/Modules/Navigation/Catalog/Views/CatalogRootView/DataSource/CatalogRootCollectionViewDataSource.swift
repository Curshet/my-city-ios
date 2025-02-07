import UIKit

class CatalogRootCollectionViewDataSource: NSObject, CatalogRootCollectionViewDataSourceProtocol {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        defaultCell(collectionView, indexPath)
    }
    
}
