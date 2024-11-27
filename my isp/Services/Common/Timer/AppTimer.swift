import Foundation
import Combine

class AppTimer: NSObject, AppTimerProtocol {
    
    let publisher: AnyPublisher<AppTimeEvent, Never>

    private weak var notificationsManager: AppNotificationsManagerEventProtocol?
    private var timer: Timer!
    private var remainder: Double
    private var repeating: Bool
    private var paused: Bool
    private var date: Date?
    private var completion: (() -> Void)?
    private var runLoop: CFRunLoop?
    private let externalPublisher: PassthroughSubject<AppTimeEvent, Never>
    private var subscriptions: Set<AnyCancellable>
    
    init(notificationsManager: AppNotificationsManagerEventProtocol?) {
        self.notificationsManager = notificationsManager
        self.remainder = .zero
        self.repeating = false
        self.paused = false
        self.externalPublisher = PassthroughSubject<AppTimeEvent, Never>()
        self.publisher = AnyPublisher(externalPublisher)
        self.subscriptions = Set<AnyCancellable>()
        super.init()
        setupObservers()
    }
    
    deinit {
        disable()
    }
    
}

// MARK: Private
private extension AppTimer {
    
    func setupObservers() {
        notificationsManager?.externalEventPublisher.sink { [weak self] in
            guard case let .application(event) = $0 else { return }
            self?.notificationsManagerEventHandler(event)
        }.store(in: &subscriptions)
    }
    
    func notificationsManagerEventHandler(_ event: AppStateEvent) {
        guard !repeating, !paused, remainder > .zero else { return }
        
        switch event {
            case .willEnterBackground:
                date = Date()
                disable()

            case .didBecomeActive:
                let present = Date()
                remainder = remainder - present.timeIntervalSince(date ?? present)
                enable(remainder, repeating, completion)
   
            default:
                break
        }
    }
    
    func enable(_ seconds: Double, _ repeats: Bool, _ action: (() -> Void)?) {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.action(seconds, repeats, action)
        }
        
        switch Thread.isMainThread {
            case true:
                RunLoop.main.add(timer, forMode: .common)
            
            case false:
                runLoop = CFRunLoopGetCurrent()
                RunLoop.current.add(timer, forMode: .common)
                RunLoop.current.run()
        }
        
        paused = false
    }
    
    func action(_ seconds: Double, _ repeats: Bool, _ action: (() -> Void)?) {
        guard remainder > 1 else {
            finish(seconds, repeats, action)
            return
        }
        
        remainder -= 1
        externalPublisher.send(.countdown(remainder))
    }
    
    func finish(_ seconds: Double, _ repeats: Bool, _ action: (() -> Void)?) {
        action?()
        
        switch repeats {
            case true:
                remainder = seconds
            
            case false:
                stop()
        }
    }
    
    func disable() {
        timer?.invalidate()
        timer = nil
        guard let runLоop = runLoop else { return }
        CFRunLoopStop(runLоop)
        runLoop = nil
    }
    
}

// MARK: Protocol
extension AppTimer {
    
    func start(seconds: Double, repeats: Bool, action: (() -> Void)?) {
        if timer != nil {
            logger.console(event: .error(info: AppTimerMessage.restart))
            externalPublisher.send(.restart)
        }
        
        guard seconds > .zero else {
            logger.console(event: .error(info: AppTimerMessage.error))
            stop()
            return
        }
        
        remainder = seconds
        repeating = repeats
        completion = action
        disable()
        enable(seconds, repeats, action)
        logger.console(event: .any(info: AppTimerMessage.start))
        externalPublisher.send(.start)
    }
    
    func pause() {
        guard timer != nil else { return }
        
        disable()
        paused = true
        logger.console(event: .any(info: AppTimerMessage.pause))
        externalPublisher.send(.pause)
    }
    
    func resume() {
        guard timer == nil, remainder > .zero else { return }
        
        enable(remainder, repeating, completion)
        logger.console(event: .any(info: AppTimerMessage.resume))
        externalPublisher.send(.resume)
    }
    
    func stop() {
        disable()
        remainder = .zero
        repeating = false
        paused = false
        date = nil
        completion = nil
        logger.console(event: .any(info: AppTimerMessage.stop))
        externalPublisher.send(.stop)
    }
    
}

// MARK: - AppTimerMessage
fileprivate enum AppTimerMessage {
    static let restart = "Timer is restarted with a new value ⏱️"
    static let error = "Timer can't start with an incorrect value ⏱️"
    static let start = "Timer is started ⏱️"
    static let pause = "Timer is paused ⏱️"
    static let resume = "Timer is resumed ⏱️"
    static let stop = "Timer is stopped ⏱️"
}

// MARK: - AppTimeEvent
enum AppTimeEvent: Equatable {
    case start
    case restart
    case countdown(Double)
    case pause
    case resume
    case stop
}
