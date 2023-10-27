import Foundation
import Moya

enum APIError: Error {
    case error(_ reason: String)
}

final class APIService {
    static let shared: APIService = .init()
    private init() {}

    private let provider = MoyaProvider<APIRequest>()
    private let decoder = JSONDecoder().then { decoder in
        decoder.dateDecodingStrategy = .secondsSince1970
    }

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

                guard let model = try? response.map(model, using: decoder) else {
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

    // Users
    case signIn(SignInInput),
         getProfile,
         getUser(Int),
         updateUser(UpdateUserInput),
         deleteUser,
         followUser(Int),
         unfollowUser(Int),
         getFollowers,
         getFollowings

    // Blogs
    case getMyBlogs,
         getBlog(Int),
         getMainBlog,
         setMainBlog(Int),
         createBlog(CreateBlogInput),
         updateBlog(Int, UpdateBlogInput),
         deleteBlog(Int)

    // Posts
    case getPosts,
         getPost(Int),
         createPost(CreatePostInput),
         updatePost(Int, UpdatePostInput)
}

extension APIRequest: TargetType {
    var baseURL: URL { .init(string: "http://ec2-13-124-25-166.ap-northeast-2.compute.amazonaws.com:8080")! }

    var path: String {
        switch self {
        case .ping:
            return "/"

        // Users
        case .signIn:
            return "/auth/sign-in"
        case .getUser:
            return "/user"
        case .getProfile, .updateUser(_), .deleteUser:
            return "/user/profile"
        case .followUser(let id):
            return "/user/follow/\(id)"
        case .unfollowUser(let id):
            return "/user/unfollow/\(id)"
        case .getFollowers:
            return "/user/followers"
        case .getFollowings:
            return "/user/followings"

        // Blogs
        case .getMyBlogs:
            return "/blog/list"
        case .getMainBlog:
            return "/blog/main"
        case .setMainBlog(let id):
            return "/blog/\(id)/main"
        case .getBlog(let id),
             .updateBlog(let id, _),
             .deleteBlog(let id):
            return "/blog/\(id)"
        case .createBlog:
            return "/blog"

        // Posts
        case .getPosts:
            return "/post/list"
        case .getPost(let id), .updatePost(let id, _):
            return "/post/\(id)"
        case .createPost:
            return "/post"
        }
    }

    var method: Moya.Method {
        switch self {
        case .ping,
             .getProfile,
             .getUser,
             .getFollowers,
             .getFollowings,
             .getMyBlogs,
             .getBlog,
             .getMainBlog,
             .getPosts,
             .getPost:
            return .get
        case .signIn,
             .followUser,
             .createBlog,
             .createPost:
            return .post
        case .updateUser,
             .updateBlog,
             .setMainBlog,
             .updatePost:
            return .patch
        case .deleteUser,
             .deleteBlog,
             .unfollowUser:
            return .delete
        }
    }

    var task: Moya.Task {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        switch self {
        case .ping,
             .getUser,
             .getProfile,
             .followUser,
             .unfollowUser,
             .getFollowers,
             .getFollowings,
             .getMyBlogs,
             .getBlog,
             .getMainBlog,
             .setMainBlog,
             .getPosts,
             .getPost,
             .deleteUser,
             .deleteBlog:
            return .requestPlain
        case .signIn(let payload):
            return .requestCustomJSONEncodable(payload, encoder: encoder)
        case .updateUser(let payload):
            return .requestCustomJSONEncodable(payload, encoder: encoder)
        case .createBlog(let payload):
            return .requestCustomJSONEncodable(payload, encoder: encoder)
        case .updateBlog(_, let payload):
            return .requestCustomJSONEncodable(payload, encoder: encoder)
        case .createPost(let payload):
            return .requestCustomJSONEncodable(payload, encoder: encoder)
        case .updatePost(_, let payload):
            return .requestCustomJSONEncodable(payload, encoder: encoder)
        }
    }

    var headers: [String: String]? {
        var headers: [String: String] = [:]
        headers.updateValue("application/json", forKey: "Content-type")

        if let accessToken = AuthViewModel.shared.accessToken {
            headers.updateValue("Bearer \(accessToken)", forKey: "Authorization")
        }

        return headers
    }
}
