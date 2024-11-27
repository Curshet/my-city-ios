import UIKit
import Combine
import SnapKit

class MoreRootCollectionCell: UICollectionViewCell {
    
    let dataPublisher: PassthroughSubject<MoreRootCollectionCellData, Never>
    
    private let view: MoreRootCollectionCellView = {
        let titleLabel = UILabel()
        let subtitleLabel = UILabel()
        let actionIcon = UIImageView()
        let view = MoreRootCollectionCellView(titleLabel: titleLabel, subtitleLabel: subtitleLabel, actionIcon: actionIcon)
        return view
    }()

    private var subscriptions: Set<AnyCancellable>
    
    override init(frame: CGRect) {
        self.dataPublisher = PassthroughSubject<MoreRootCollectionCellData, Never>()
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: frame)
        startConfiguration()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Private
private extension MoreRootCollectionCell {
    
    func startConfiguration() {
        setupObservers()
        setupLayout()
    }
    
    func setupObservers() {
        dataPublisher.sink { [weak self] in
            self?.view.dataPublisher.send($0)
        }.store(in: &subscriptions)
    }
    
    func setupLayout() {
        addSubview(view)

        view.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
}
