import UIKit

extension UIAlertController {
    
    static func create(_ content: AlertContent) -> UIAlertController {
        let controller: UIAlertController
        
        switch content.type {
            case .oneButton(let model):
                let action = UIAlertAction(title: model.title, style: model.style) { _ in model.action?() }
                controller = UIAlertController(title: content.title, message: content.message, preferredStyle: content.style)
                controller.addAction(action)
            
            case .twoButtons(let left, let right):
                let leftAction = UIAlertAction(title: left.title, style: left.style) { _ in left.action?() }
                let rightAction = UIAlertAction(title: right.title, style: right.style) { _ in right.action?() }
                controller = UIAlertController(title: content.title, message: content.message, preferredStyle: content.style)
                controller.addAction(rightAction)
                controller.addAction(leftAction)
            
            case .someButtons(let models):
                controller = UIAlertController(title: content.title, message: content.message, preferredStyle: content.style)
                models.forEach { model in let action = UIAlertAction(title: model.title, style: model.style) { _ in model.action?() }; controller.addAction(action) }
        }
        
        return controller
    }
    
}

// MARK: - AlertContent
struct AlertContent {
    let style: UIAlertController.Style
    let title: String
    let message: String
    let type: AlertType
}

// MARK: - AlertType
enum AlertType {
    case oneButton(AlertButton)
    case twoButtons(left: AlertButton, right: AlertButton)
    case someButtons([AlertButton])
}

// MARK: - AlertButton
struct AlertButton {
    let title: String
    let style: UIAlertAction.Style
    let action: (() -> Void)?
}
