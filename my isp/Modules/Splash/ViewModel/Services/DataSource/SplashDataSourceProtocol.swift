import Foundation
import Combine

protocol SplashDataSourceProtocol {
    var internalEventPublisher: PassthroughSubject<SplashDataSourceInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<SplashDataSourceExternalEvent, Never> { get }
}
