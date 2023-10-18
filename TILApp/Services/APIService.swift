import Foundation
import Moya

enum APIService {
    case ping
}

extension APIService: TargetType {
    var baseURL: URL { .init(string: "http://ec2-13-124-25-166.ap-northeast-2.compute.amazonaws.com:8080")! }

    var path: String {
        switch self {
        case .ping:
            return "/"
        }
    }

    var method: Moya.Method {
        switch self {
        case .ping:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case .ping:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
