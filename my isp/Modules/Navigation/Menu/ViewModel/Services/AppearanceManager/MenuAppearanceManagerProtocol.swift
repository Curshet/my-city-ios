import Foundation
import Combine

protocol MenuAppearanceManagerProtocol {
    var internalEventPublisher: PassthroughSubject<MenuPresenterData, Never> { get }
    var externalEventPublisher: AnyPublisher<MenuAppearancePresenterExternalEvent, Never> { get }
}
