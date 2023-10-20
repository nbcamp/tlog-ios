import Foundation
import Moya

final class APIService {
    static let shared: APIService = .init()
    private init() {}

    private let provider = MoyaProvider<APIRequest>()

    func request(
        _ target: APIRequest,
        onSuccess: @escaping (_ response: Response) -> Void,
        onError: ((_ error: MoyaError) -> Void)? = nil
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                guard let response = try? response.filterSuccessfulStatusAndRedirectCodes() else {
                    onError?(.statusCode(response)); return
                }
                onSuccess(response)
            case .failure(let error):
                onError?(error)
            }
        }
    }

    func request<Model: Decodable>(
        _ target: APIRequest,
        model: Model.Type,
        onSuccess: @escaping (_ model: Model) -> Void,
        onError: ((_ error: MoyaError) -> Void)? = nil
    ) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                guard let response = try? response.filterSuccessfulStatusCodes() else {
                    onError?(.statusCode(response)); return
                }
                guard let model = try? response.map(model) else {
                    onError?(.jsonMapping(response)); return
                }
                onSuccess(model)
            case .failure(let error):
                onError?(error)
            }
        }
    }
}

enum APIRequest {
    case ping
    case signIn(SignInInput)
    case profile
}

extension APIRequest: TargetType {
    var baseURL: URL { .init(string: "http://ec2-13-124-25-166.ap-northeast-2.compute.amazonaws.com:8080")! }

    var path: String {
        switch self {
        case .ping:
            return "/"
        case .signIn(_:):
            return "/auth/sign-in"
        case .profile:
            return "/users/profile"
        }
    }

    var method: Moya.Method {
        switch self {
        case .ping, .profile:
            return .get
        case .signIn(_:):
            return .post
        }
    }

    var task: Moya.Task {
        switch self {
        case .ping, .profile:
            return .requestPlain
        case .signIn(let payload):
            return .requestJSONEncodable(payload)
        }
    }

    var headers: [String: String]? {
        var headers: [String: String] = [:]
        headers.updateValue("application/json", forKey: "Content-type")

        if let accessToken = AuthService.shared.accessToken {
            headers.updateValue("Bearer \(accessToken)", forKey: "Authorization")
        }
        return headers
    }
}
