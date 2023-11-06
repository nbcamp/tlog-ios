import Foundation
import Moya
import MoyaSugar

enum APIError: Error {
    case error(_ reason: String)
}

private enum Coder {
    static let encoder = JSONEncoder().then { $0.dateEncodingStrategy = .secondsSince1970 }
    static let decoder = JSONDecoder().then { $0.dateDecodingStrategy = .secondsSince1970 }
}

typealias Handler<T, E: Error> = (_ result: APIResult<T>) -> Void
typealias APIResult<T> = Result<T, MoyaError>
typealias APIHandler<T> = Handler<T, MoyaError>

final class APIService {
    static let shared: APIService = .init()
    private init() {}

    private let provider = MoyaSugarProvider<APIRequest>(plugins: [
        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)) // 디버그 용
    ])

    func request(_ target: APIRequest, handler: @escaping APIHandler<Response>) {
        provider.request(target) { [unowned self] result in
            switch result {
            case .success(let response):
                guard let response = try? response.filterSuccessfulStatusCodes() else {
                    if let message = getErrorMessage(of: response) {
                        return handler(.failure(.underlying(APIError.error(message), response)))
                    }
                    return handler(.failure(.statusCode(response)))
                }
                return handler(.success(response))
            case .failure(let error):
                return handler(.failure(error))
            }
        }
    }
    
    func request(_ target: APIRequest) async -> APIResult<Response> {
        return await withCheckedContinuation { [unowned self] continuation in
            request(target) { continuation.resume(returning: $0) }
        }
    }

    func request<Model: Decodable>(_ target: APIRequest, to model: Model.Type, _ handler: @escaping APIHandler<Model>) {
        provider.request(target) { [unowned self] result in
            switch result {
            case .success(let response):
                guard let response = try? response.filterSuccessfulStatusCodes() else {
                    if let message = getErrorMessage(of: response) {
                        return handler(.failure(.underlying(APIError.error(message), response)))
                    }
                    return handler(.failure(.statusCode(response)))
                }
                guard let model = try? response.map(model, using: Coder.decoder) else {
                    printJsonAsString(json: response.data)
                    return handler(.failure(.jsonMapping(response)))
                }
                return handler(.success(model))
            case .failure(let error):
                return handler(.failure(error))
            }
        }
    }

    func request<Model: Decodable>(_ target: APIRequest, to model: Model.Type) async -> APIResult<Model> {
        return await withCheckedContinuation { [unowned self] continuation in
            request(target, to: model) { continuation.resume(returning: $0) }
        }
    }

    private func getErrorMessage(of response: Response) -> String? {
        guard let error = try? response.mapJSON(),
              let error = error as? [String: Any],
              let error = error["error"] as? String
        else { return nil }
        return error
    }

    private func printJsonAsString(json: Data) {
        if let string = String(data: json, encoding: .utf8) {
            debugPrint(string)
        } else {
            debugPrint("Failed to convert data to string.")
        }
    }
}

enum APIRequest {
    // Status Check
    case ping

    // Authenticate
    case signIn(_ input: SignInInput)

    // My Profile
    case getMyProfile,
         updateMyProfile(_ input: UpdateUserInput),
         withdrawMe

    // My Blogs
    case getMyBlogs,
         getMyBlog(_ blogId: Int),
         createMyBlog(_ input: CreateBlogInput),
         updateMyBlog(_ blogId: Int, _ input: UpdateBlogInput),
         deleteMyBlog(_ blogId: Int),
         getMyMainBlog,
         setMyMainBlog(_ blogId: Int)

    // My Posts
    case getMyPosts,
         getMyPost(_ postId: Int)

    // My Posts of Blog
    case getMyBlogPosts(_ blogId: Int),
         getMyBlogPost(_ blogId: Int, _ postId: Int),
         createMyBlogPost(_ blogId: Int, _ input: CreatePostInput)

    // My Liked Posts
    case getMyLikedPosts,
         likePost(_ postId: Int),
         unlikePost(_ postId: Int)

    // My Follow
    case getMyFollowers,
         getMyFollowings,
         followUser(_ userId: Int),
         unfollowUser(_ userId: Int),
         deleteMyFollower(_ userId: Int)

    // User's Information
    case getUserProfile(_ userId: Int),
         getUserBlogs(_ userId: Int),
         getUserMainBlog(_ userId: Int),
         getUserPosts(_ userId: Int),
         getUserLikedPosts(_ userId: Int)

    // Community
    case getCommunityPosts(GetCommunityQuery)
}

extension APIRequest: SugarTargetType {
    var baseURL: URL { .init(string: "http://localhost:8080")! }

    var route: MoyaSugar.Route {
        switch self {
        // Status Check
        case .ping: return .get("/")

        // Authenticate
        case .signIn: return .post("/auth/sign-in")

        // My Profile
        case .getMyProfile: return .get("/my/profile")
        case .updateMyProfile: return .patch("/my/profile")
        case .withdrawMe: return .delete("/my/profile")

        // My Blogs
        case .getMyBlogs: return .get("/my/blogs")
        case .createMyBlog: return .post("/my/blogs")
        case .getMyBlog(let blogId): return .get("/my/blogs/\(blogId)")
        case .updateMyBlog(let blogId, _): return .patch("/my/blogs/\(blogId)")
        case .deleteMyBlog(let blogId): return .delete("/my/blogs/\(blogId)")
        case .getMyMainBlog: return .get("/my/blogs/main")
        case .setMyMainBlog(let blogId): return .patch("/my/blogs/\(blogId)/main")

        // My Posts
        case .getMyPosts: return .get("/my/posts")
        case .getMyPost(let postId): return .get("/my/posts/\(postId)")

        // My Posts of Blog
        case .getMyBlogPosts(let blogId): return .get("/my/blogs/\(blogId)/posts")
        case .getMyBlogPost(let blogId, let postId): return .get("/my/blogs/\(blogId)/posts/\(postId)")
        case .createMyBlogPost(let blogId, _): return .post("/my/blogs/\(blogId)/posts")

        // My Liked Posts
        case .getMyLikedPosts: return .get("/my/likes/posts")
        case .likePost(let postId): return .post("/my/likes/posts/\(postId)")
        case .unlikePost(let postId): return .delete("/my/likes/posts/\(postId)")

        // My Follows
        case .getMyFollowers: return .get("/my/followers")
        case .getMyFollowings: return .get("/my/followings")
        case .followUser(let userId): return .post("/my/followings/\(userId)")
        case .unfollowUser(let userId): return .delete("/my/followings/\(userId)")
        case .deleteMyFollower(let userId): return .delete("/my/followers/\(userId)")

        // User's Information
        case .getUserProfile(let userId): return .get("/users/\(userId)")
        case .getUserBlogs(let userId): return .get("/users/\(userId)/blogs")
        case .getUserMainBlog(let userId): return .get("/users/\(userId)/blogs/main")
        case .getUserPosts(let userId): return .get("/users/\(userId)/posts")
        case .getUserLikedPosts(let userId): return .get("/users/\(userId)/likes/posts")

        // Community
        case .getCommunityPosts: return .get("/community/posts")
        }
    }

    var parameters: MoyaSugar.Parameters? {
        switch self {
        case .signIn(let input): return toBody(input)
        case .updateMyProfile(let input): return toBody(input)
        case .createMyBlog(let input): return toBody(input)
        case .updateMyBlog(_, let input): return toBody(input)
        case .createMyBlogPost(_, let input): return toBody(input)
        case .getCommunityPosts(let query): return toParam(query)
        default: return .none
        }
    }

    private func toBody<T: Codable>(_ input: T) -> MoyaSugar.Parameters? {
        JSONEncoding() => toDictionary(from: input, with: Coder.encoder)
    }
    
    private func toParam<T: Codable>(_ input: T) -> MoyaSugar.Parameters? {
        URLEncoding() => toDictionary(from: input, with: Coder.encoder)
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
