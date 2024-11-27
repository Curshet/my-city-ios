import UIKit
import Combine

class MoreSupportPhoneCell: AppCollectionViewCell<MoreSupportPhoneCellView, MoreSupportPhoneCellContent> {
    
    private var action: ((MoreSupportViewModelSelectEvent) -> Void)?
    private var view: MoreSupportPhoneCellView!
    private var subscriptions: Set<AnyCancellable>
    
    override init(frame: CGRect) {
        self.subscriptions = Set<AnyCancellable>()
        super.init(frame: frame)
        setupObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Private
private extension MoreSupportPhoneCell {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }

    func internalEventHandler(_ event: AppCollectionViewCellInternalEvent<View, Data>) {
        switch event {
            case .inject(let view):
                setupLayout(view)
            
            case .data(let value):
                action = value.action
                view?.internalEventPublisher.send(value.data)
        }
    }
    
    func setupLayout(_ customView: MoreSupportPhoneCellView?) {
        guard subviews.isEmpty, let customView else { return }
        
        view = customView
        addSubview(view)
        
        view?.externalEventPublisher.sink { [weak self] in
            self?.action?($0)
        }.store(in: &subscriptions)
    }
    
}
