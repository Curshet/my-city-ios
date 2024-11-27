import UIKit
import Combine

class MoreSettingsSecurityCell: AppCollectionViewCell<MoreSettingsSecurityCellView, MoreSettingsSecurityCellContent> {

    private var action: ((MoreSettingsViewModelSelectEvent) -> Void)?
    private var view: MoreSettingsSecurityCellView!
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
private extension MoreSettingsSecurityCell {
    
    func setupObservers() {
        internalEventPublisher.sink { [weak self] in
            self?.internalEventHandler($0)
        }.store(in: &subscriptions)
    }
    
    func internalEventHandler(_ event: AppCollectionViewCellInternalEvent<View, Data>) {
        switch event {
            case .inject(let view):
                setupLayout(view)
            
            case .data(let content):
                action = content.action
                view?.internalEventPublisher.send(content.data)
        }
    }
    
    func setupLayout(_ customView: MoreSettingsSecurityCellView?) {
        guard subviews.isEmpty, let customView else { return }

        view = customView
        addSubview(view)

        view?.externalEventPublisher.sink { [weak self] in
            self?.action?($0)
        }.store(in: &subscriptions)
    }

}
