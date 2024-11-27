import UIKit
import Combine

class AppCollectionViewCell<View: UIView, Data>: UICollectionViewCell, AppCollectionViewCellProtocol {
    
    typealias View = View
    typealias Data = Data
    
    let internalEventPublisher: PassthroughSubject<AppCollectionViewCellInternalEvent<View, Data>, Never>
    
    override init(frame: CGRect) {
        self.internalEventPublisher = PassthroughSubject<AppCollectionViewCellInternalEvent<View, Data>, Never>()
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - AppCollectionViewCellInternalEvent
enum AppCollectionViewCellInternalEvent<View: UIView, Data> {
    case inject(View)
    case data(Data)
}
