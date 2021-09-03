
import Foundation
import Combine

extension Publisher {
    
    public func printForDebugging(_ options: FMRest.ServerOptions) -> AnyPublisher<Output, Failure> {
        handleEvents(
            receiveSubscription: {
                if case .print(let label) = options.printDebug.publisherReceiveSubscription {
                    Swift.print("\(label ?? "") \($0)")
                }
            },
            receiveOutput: {
                if case .print(let label) = options.printDebug.publisherReceiveOutput {
                    Swift.print("\(label ?? "") \($0)")
                }
            },
            receiveCompletion: {
                if case .print(let label) = options.printDebug.publisherReceiveCompletion {
                    Swift.print("\(label ?? "") \($0)")
                }
            },
            receiveCancel: {
                if case .print(let label) = options.printDebug.publisherReceiveCancel {
                    Swift.print("\(label ?? "") Cancel")
                }
            },
            receiveRequest: {
                if case .print(let label) = options.printDebug.publisherReceiveRequest {
                    Swift.print("\(label ?? "") \($0)")
                }
            })
            .eraseToAnyPublisher()
    }
    
}
