import Foundation
import Combine

protocol AppearanceManagerProtocol {
    var internalEvеntPublishеr: PassthroughSubject<AppearanceManagerInternalEvent, Never> { get }
    var extеrnalEvеntPublisher: AnyPublisher<AppearanceManagerExternalEvent, Never> { get }
    var information: AppearancePresenterData { get }
}
