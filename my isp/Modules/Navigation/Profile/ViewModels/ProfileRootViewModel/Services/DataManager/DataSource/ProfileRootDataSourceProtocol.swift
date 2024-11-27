import Foundation
import Combine

protocol ProfileRootDataSourceProtocol {
    var internalEventPublisher: PassthroughSubject<ProfileRootDataSourceInternalEvent, Never> { get }
    var externalEventPublisher: AnyPublisher<ProfileRootDataSourceExternalEvent, Never> { get }
}
