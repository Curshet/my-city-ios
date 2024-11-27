import Foundation
import Combine

protocol AppearancePresenterProtocol {
    var internalEvеntPublisher: PassthroughSubject<AppearancePresenterInternalEvent, Never> { get }
    var information: AppearancePresenterData { get }
}
