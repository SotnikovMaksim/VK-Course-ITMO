import Foundation
import Combine

public typealias JobWorker<Key: Hashable, Output, Failure: Error> =
    @Sendable (Key, @Sendable @escaping (Result<Output, Failure>) -> Void) -> Void

/// Трекер задач
/// Является основой для протоколов ``CallbackJobTracking``, ``AsyncJobTracking``, и ``ReactiveJobTracking``
public protocol JobTracking {
    associatedtype Key: Hashable
    associatedtype Output
    associatedtype Failure: Error

    /// Обязательный конструктор
    /// - Parameters:
    ///   - memoizationOptions: флаги мемоизации. Управляют поведением трекера для задач с одинаковыми идентификаторами. См. ``MemoizationOptions.``
    ///   - worker: Блок worker. Вызвается каждый раз, когда должна стартовать задача.
    ///     - Принимает на вход ключ задачи и блок completion, который может быть вызван асинхронно (в любом потоке).
    init(
        memoizing: MemoizationOptions,
        worker: @escaping JobWorker<Key, Output, Failure>
    )
}

public protocol CallbackJobTracking: JobTracking {
    /// Запустить задачу
    /// - Parameters:
    ///   - key: Ключ задачи, передаваемый в блок worker. Также будет использован для сравнения с ранее выполнявшимися задачами.
    ///   - completion: Блок завершения. Будет вызван с результатом выполнения задачи.
    func startJob(for key: Key, completion: @escaping (Result<Output, Failure>) -> Void)
}

public protocol AsyncJobTracking: JobTracking {
    /// Запустить задачу
    /// - Parameter key: Ключ задачи, передаваемый в блок worker. Также будет использован для сравнения с ранее выполнявшимися задачами.
    /// - Returns: Результат выполнения задачи
    /// - Throws: Ошибку, выброшенную блоком worker
    func startJob(for key: Key) async throws -> Output
}

public protocol PublishingJobTracking: JobTracking {
    associatedtype JobPublisher: Publisher where Output == Self.Output, Failure == Self.Failure
    
    /// Запустить задачу
    /// - Parameter key: Ключ задачи, передаваемый в блок worker. Также будет использован для сравнения с ранее выполнявшимися задачами.
    /// - Returns: Паблишер с результатом выполнения задачи либо ошибкой, доступными для каждого нового подписчика.
    func startJob(for key: Key) -> JobPublisher
}

/// Опции запоминания результатов задач в трекере
public struct MemoizationOptions: OptionSet {
    /// Запоминать начатые задачи
    /// Если этот флаг выставлен, TaskTracker осуществляет дедупликацию задач. Если задача с заданным идентификатором уже выполняется, нового вызова блока worker не происходит. Вместо этого переданный в метод start блок completion будет вызван вместе с блоком completion, переданным в вызов start, который привёл к старту задачи.
    /// Если любой другой флаг в этом перечислении выставлен, этот флаг также считается выставленным.
    public static let started = Self(rawValue: 1 << 1)

    /// Запоминать задачи, завершившиеся с ошибкой
    /// Если задача с заданным идентификатором ранее уже завершалась с ошибкой, блок completion должен быть вызван с результатом в виде этой ошибки. В противном случае поведение должно соответствовать остальным выставленным флагам.
    public static let failed: Self = [.started, Self(rawValue: 1 << 2)]

    /// Запоминать успешно завершённые задачи
    /// Если задача с заданным идентификатором ранее уже завершалась успешно с некоторым результатом, блок completion должен быть вызван с этим результатом. В противном случае поведение должно соответствовать остальным выставленным флагам.
    public static let succeeded: Self = [.started, Self(rawValue: 1 << 3)]

    /// Запоминать любые завершившиеся задачи
    /// Поведение соответствует обоим выставленным флагам: succeded и failed.
    public static let completed: Self = [.succeeded, .failed]

    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}


public class GCDJobTracker<Key: Hashable, Output, Faulure: Error>: CallbackJobTracking {
    enum JobState {
        case running(awaitingCallbacks: [(Result<Output, Faulure>) -> Void])
        case completed(result: Result<Output, Failure>)
    }
    
    public typealias Failure = Faulure
    public typealias Output = Output
    public typealias Key = Key
    
    private var states: [Key: JobState] = [:]
    
    private let queue = DispatchQueue(label: "GCDJobTrackerQueue", qos: .utility)
    
    private let worker: JobWorker<Key, Output, Faulure>
    
    private let memoryFlags: MemoizationOptions
    
    public required init(memoizing: MemoizationOptions, worker: @escaping JobWorker<Key, Output, Failure>) {
        self.memoryFlags = memoizing
        self.worker = worker
    }
    
    public func startJob(for key: Key, completion: @escaping (Result<Output, Failure>) -> Void) {
        guard let state = self.states[key] else {
            states[key] = .running(awaitingCallbacks: [completion])
            
            self.queue.async {
                self.worker(key) { result in
                    DispatchQueue.main.async {
                        switch self.states[key] {
                        case .running(let callbacks):
                            for callback in callbacks {
                                callback(result)
                            }
                        default:
                            return
                        }
                        
                        self.states[key] = .completed(result: result)
                    }
                }
            }

            return
        }
        
        if memoryFlags.contains(.started) {
            switch state {
            case .running(let awaiters):
                self.states[key] = .running(awaitingCallbacks: awaiters + [completion])
            case .completed(let result):
                var resultState: MemoizationOptions
                completion(result)
                
                switch result {
                case .success(_):
                    resultState = .succeeded
                case .failure(_):
                    resultState = .failed
                }
                
                if memoryFlags != .completed && memoryFlags != resultState {
                    self.states.removeValue(forKey: key)
                }
            }
        } else {
            self.queue.async {
                self.worker(key) { _ in }
            }
        }
    }
}
