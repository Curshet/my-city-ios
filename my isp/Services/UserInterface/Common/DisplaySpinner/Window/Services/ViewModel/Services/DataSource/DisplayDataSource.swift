import Foundation

final class DisplayDataSource: DisplayDataSourceWindowProtocol, DisplayDataSourceViewProtocol {

    var layout: DisplayWindowLayout {
        DisplayWindowLayout(duration: 0.2, alphaOne: 1, alphaTwo: 0)
    }

    func layout(customized: DisplayViewLayout?) -> AppOverlayViewLayout {
        switch customized {
            case .some(let value):
                AppOverlayViewLayout(activityIndicator: nil, effect: value.effect, backgroundColor: value.backgroundColor, cornerRadius: .zero, startDelay: .zero, stopDelay: .zero)
            
            case nil:
                AppOverlayViewLayout(activityIndicator: nil, effect: nil, backgroundColor: .interfaceManager.blackTwo(alpha: 0.15), cornerRadius: 0, startDelay: 0, stopDelay: 0.2)
        }
    }
    
}
