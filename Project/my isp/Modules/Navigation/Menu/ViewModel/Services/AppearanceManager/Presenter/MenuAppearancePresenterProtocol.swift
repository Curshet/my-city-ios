import Foundation
import Combine

protocol MenuAppearancePresenterProtocol {
    var internalEventPublisher: PassthroughSubject<MenuAppearancePresenterInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<MenuAppearancePresenterExternalEvent, Never> { get }
}
