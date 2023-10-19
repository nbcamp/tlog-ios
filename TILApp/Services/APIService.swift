import Foundation
import Moya

enum APIService {
    case ping
    case signIn(SignInInput)
}

extension APIService: TargetType {
    var baseURL: URL { .init(string: "http://ec2-13-124-25-166.ap-northeast-2.compute.amazonaws.com:8080")! }

    var path: String {
        switch self {
        case .ping:
            return "/"
        case .signIn(_:):
            return "/auth/sign-in"
        }
    }

    var method: Moya.Method {
        switch self {
        case .ping:
            return .get
        case .signIn(_:):
            return .post
        }
    }

    var task: Moya.Task {
        switch self {
        case .ping:
            return .requestPlain
        case .signIn(let payload):
            return .requestJSONEncodable(payload)
        }
    }

    var headers: [String: String]? {
        var headers: [String: String] = [:]
        headers.updateValue("application/json", forKey: "Content-type")

        if let accessToken = AuthService.shared.accessToken {
            headers.updateValue(accessToken, forKey: "Authorization")
        }

        return headers
    }
}
