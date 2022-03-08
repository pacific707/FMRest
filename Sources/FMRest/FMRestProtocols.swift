
import Foundation

public protocol EndpointPath {
    
    var path: String { get }
    
}

public protocol FMRestServer {
    
    var host: String { get }
    var config: FMRestConfig { get }
     
}

public protocol FMRestConfig {
    
    var version: String { get set }
    var scheme: String { get set }
    var rootPath: String { get set }
    var decoder: JSONDecoder { get set }
    var encoder: JSONEncoder { get set }
    var options: FMRest.ServerOptions { get set }
}

public protocol FMRestCredentials {
    
    var headers: [FMRest.Header] { get }
    
}

