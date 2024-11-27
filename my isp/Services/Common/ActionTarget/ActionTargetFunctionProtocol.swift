import Foundation

@objc protocol ActionTargetFunctionProtocol {
    func touchDown()
    func touchDownRepeat()
    func touchDragInside()
    func touchDragOutside()
    func touchDragEnter()
    func touchDragExit()
    func touchUpInside()
    func touchUpOutside()
    func touchCancel()
    func valueChanged()
    func primaryActionTriggered()
    func editingDidBegin()
    func editingChanged()
    func editingDidEnd()
    func editingDidEndOnExit()
    func allTouchEvents()
    func allEditingEvents()
    func applicationReserved()
    func systemReserved()
    func allEvents()
}
