import Combine
import Foundation
import Moya
import MoyaSugar
import UIKit

enum APIError: Error {
    case error(_ reason: String)
}

private enum Coder {
    static let encoder = JSONEncoder().then { $0.dateEncodingStrategy = .secondsSince1970 }
    static let decoder = JSONDecoder().then { $0.dateDecodingStrategy = .secondsSince1970 }
}

typealias Handler<T, E: Error> = (_ result: APIResult<T>) -> Void
typealias APIResult<T> = Result<T, APIError>
typealias APIHandler<T> = Handler<T, APIError>

final class APIService {
    static let shared: APIService = .init()
    private init() {}

    private let provider = MoyaSugarProvider<APIRequest>(plugins: [
          // NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)) // 디버그 용
    ])

    func request(_ target: APIRequest, handler: @escaping APIHandler<Response>) {
        provider.request(target) { [unowned self] result in
            switch result {
            case .success(let response):
                guard let response = try? response.filterSuccessfulStatusCodes() else {
                    if let message = getErrorMessage(of: response) {
                        return handler(.failure(.error(message)))
                    }
                    return handler(.failure(.error("예상치 못한 에러가 발생했습니다.")))
                }
                return handler(.success(response))
            case .failure(let error):
                debugPrint(#function, error)
                if let response = error.response, let message = getErrorMessage(of: response) {
                    return handler(.failure(.error(message)))
                }
                return handler(.failure(.error("예상치 못한 에러가 발생했습니다.")))
            }
        }
    }

    func request(_ target: APIRequest) async throws -> Response {
        return try await withCheckedThrowingContinuation { [unowned self] continuation in
            request(target) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func request(_ target: APIRequest) -> AnyPublisher<Response, APIError> {
        return Future { [unowned self] promise in
            request(target) { promise($0) }
        }.eraseToAnyPublisher()
    }

    func request<Model: Decodable>(_ target: APIRequest, to model: Model.Type, _ handler: @escaping APIHandler<Model>) {
        provider.request(target) { [unowned self] result in
            switch result {
            case .success(let response):
                guard let response = try? response.filterSuccessfulStatusCodes() else {
                    if let message = getErrorMessage(of: response) {
                        return handler(.failure(.error(message)))
                    }
                    return handler(.failure(.error("예상치 못한 에러가 발생했습니다.")))
                }
                guard let model = try? response.map(model, using: Coder.decoder) else {
                    printJsonAsString(json: response.data, to: model)
                    return handler(.failure(.error("잘못된 응답입니다.")))
                }
                return handler(.success(model))
            case .failure(let error):
                debugPrint(#function, error)
                if let response = error.response, let message = getErrorMessage(of: response) {
                    return handler(.failure(.error(message)))
                }
                return handler(.failure(.error("예상치 못한 에러가 발생했습니다.")))
            }
        }
    }

    func request<Model: Decodable>(_ target: APIRequest, to model: Model.Type) async throws -> Model {
        return try await withCheckedThrowingContinuation { [unowned self] continuation in
            request(target, to: model) { result in
                switch result {
                case .success(let response): continuation.resume(returning: response)
                case .failure(let error): continuation.resume(throwing: error)
                }
            }
        }
    }

    func request<Model: Decodable>(_ target: APIRequest, to model: Model.Type) -> AnyPublisher<Model, APIError> {
        return Future { [unowned self] promise in
            request(target, to: model) { promise($0) }
        }.eraseToAnyPublisher()
    }

    private func getErrorMessage(of response: Response) -> String? {
        guard let error = try? response.mapJSON(),
              let error = error as? [String: Any],
              let error = error["error"] as? String
        else { return nil }
        return error
    }

    private func printJsonAsString<Model>(json: Data, to model: Model) {
        debugPrint("[\(#function)] Failed to convert json to data(\(String(describing: model))")
        if let string = String(data: json, encoding: .utf8) {
            debugPrint("Stringify:", string)
        }
    }
}

enum APIRequest {
    // Status Check
    case ping

    // Authenticate
    case signIn(_ input: SignInInput)

    // Upload File
    case uploadImage(_ image: UIImage)

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
         getMyMainBlog

    // My Posts
    case getMyPosts,
         getMyPost(_ postId: Int),
         getMyLikedPosts

    // My Posts of Blog
    case getMyBlogPosts(_ blogId: Int),
         getMyBlogPost(_ blogId: Int, _ postId: Int),
         createMyBlogPost(_ blogId: Int, _ input: CreatePostInput)

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
    case getCommunityPosts(GetCommunityQuery),
         likePost(_ postId: Int),
         unlikePost(_ postId: Int)
}

extension APIRequest: SugarTargetType {
    var baseURL: URL { .init(string: "http://ec2-13-124-25-166.ap-northeast-2.compute.amazonaws.com:8080")! }

    var route: MoyaSugar.Route {
        switch self {
        // Status Check
        case .ping: return .get("/")

        // Authenticate
        case .signIn: return .post("/auth/sign-in")

        // Upload File
        case .uploadImage: return .post("/upload/image")

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

        // My Posts
        case .getMyPosts: return .get("/my/posts")
        case .getMyPost(let postId): return .get("/my/posts/\(postId)")
        case .getMyLikedPosts: return .get("/my/liked-posts")

        // My Posts of Blog
        case .getMyBlogPosts(let blogId): return .get("/my/blogs/\(blogId)/posts")
        case .getMyBlogPost(let blogId, let postId): return .get("/my/blogs/\(blogId)/posts/\(postId)")
        case .createMyBlogPost(let blogId, _): return .post("/my/blogs/\(blogId)/posts")

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
        case .getUserLikedPosts(let userId): return .get("/users/\(userId)/liked-posts")

        // Community
        case .getCommunityPosts: return .get("/community/posts")
        case .likePost(let postId): return .post("/community/posts/\(postId)/likes")
        case .unlikePost(let postId): return .delete("/community/posts/\(postId)/likes")
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

    var task: Task {
        switch self {
        case .uploadImage(let image):
            guard let data = image
                .resized(to: .init(width: 100, height: 100))
                .jpegData(compressionQuality: 0.3)
            else { return .requestPlain }

            return .uploadMultipart([.init(
                provider: .data(data),
                name: "file",
                fileName: "image.jpg",
                mimeType: "image/jpeg"
            )])
        default:
            guard let parameters else { return .requestPlain }
            return .requestParameters(parameters: parameters.values, encoding: parameters.encoding)
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
        if let accessToken = AuthViewModel.shared.accessToken {
            headers.updateValue("Bearer \(accessToken)", forKey: "Authorization")
        }

        switch self {
        case .uploadImage:
            headers.updateValue("multipart/form-data", forKey: "Content-type")
        default:
            headers.updateValue("application/json", forKey: "Content-type")
        }
        return headers
    }
}
