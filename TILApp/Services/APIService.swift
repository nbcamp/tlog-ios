import Foundation
import Moya

enum APIError: Error {
    case error(_ reason: String)
}

final class APIService {
    static let shared: APIService = .init()
    private init() {}

    private let provider = MoyaProvider<APIRequest>()

    func request(
        _ target: APIRequest,
        onSuccess: @escaping (_ response: Response) -> Void,
        onError: ((_ error: MoyaError) -> Void)? = nil
    ) {
        provider.request(target) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                guard let response = try? response.filterSuccessfulStatusCodes() else {
                    if let message = getErrorMessage(of: response) {
                        onError?(.underlying(APIError.error(message), response)); return
                    }
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
        provider.request(target) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                guard let response = try? response.filterSuccessfulStatusCodes() else {
                    if let message = getErrorMessage(of: response) {
                        onError?(.underlying(APIError.error(message), response)); return
                    }
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

    private func getErrorMessage(of response: Response) -> String? {
        guard let error = try? response.mapJSON(),
              let error = error as? [String: Any],
              let error = error["error"] as? String
        else { return nil }
        return error
    }
}

enum APIRequest {
    case ping

    case signIn(SignInInput),
         getUser,
         updateUser(UpdateUserInput),
         deleteUser

    case getBlogs,
         getBlog(Int),
         createBlog(CreateBlogInput),
         updateBlog(Int, UpdateBlogInput),
         deleteBlog(Int)

    case getPosts,
         getPost(Int),
         updatePost(Int, UpdatePostInput)
}

extension APIRequest: TargetType {
    var baseURL: URL { .init(string: "http://ec2-13-124-25-166.ap-northeast-2.compute.amazonaws.com:8080")! }

    var path: String {
        switch self {
        case .ping:
            return "/"
        case .signIn:
            return "/auth/sign-in"
        case .getUser, .updateUser(_), .deleteUser:
            return "/users/profile"
        case .getBlogs, .createBlog:
            return "/blogs"
        case .getBlog(let id),
             .updateBlog(let id, _),
             .deleteBlog(let id):
            return "/blogs/\(id)"
        case .getPosts:
            return "/posts"
        case .getPost(let id), .updatePost(let id, _):
            return "/post/\(id)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .ping, .getUser, .getBlogs, .getBlog(_), .getPosts, .getPost:
            return .get
        case .signIn(_), .createBlog:
            return .post
        case .updateUser(_), .updateBlog(_, _), .updatePost:
            return .patch
        case .deleteUser, .deleteBlog:
            return .delete
        }
    }

    var task: Moya.Task {
        switch self {
        case .ping,
             .getUser,
             .getBlogs,
             .getBlog(_),
             .getPosts,
             .getPost(_),
             .deleteUser,
             .deleteBlog:
            return .requestPlain
        case .signIn(let payload):
            return .requestJSONEncodable(payload)
        case .updateUser(let payload):
            return .requestJSONEncodable(payload)
        case .createBlog(let payload):
            return .requestJSONEncodable(payload)
        case .updateBlog(_, let payload):
            return .requestJSONEncodable(payload)
        case .updatePost(_, let payload):
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
