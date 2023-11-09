import Dispatch

final class PostViewModel {
    static let shared: PostViewModel = .init()
    private init() {}

    private let api = APIService.shared

    private(set) var myPosts: [Post] = []
    private(set) var myLikedPosts: [CommunityPost] = []

    func withMyPosts(_ handler: @escaping APIHandler<[Post]>) {
        api.request(.getMyPosts, to: [Post].self) { [unowned self] result in
            if case let .success(model) = result {
                myPosts = model
            }
            handler(result)
        }
    }

    func withMyLikedPosts(_ handler: @escaping APIHandler<[CommunityPost]>) {
        api.request(.getMyLikedPosts, to: [CommunityPost].self) { [unowned self] result in
            if case let .success(model) = result {
                myLikedPosts = model
            }
            handler(result)
        }
    }

    func withUserPosts(user: User, _ handler: @escaping APIHandler<[Post]>) {
        api.request(.getUserPosts(user.id), to: [Post].self, handler)
    }

    func withUserLikedPosts(user: User, _ handler: @escaping APIHandler<[CommunityPost]>) {
        api.request(.getUserLikedPosts(user.id), to: [CommunityPost].self, handler)
    }

    func create(blog: Blog, _ inputs: [CreatePostInput], _ handler: @escaping APIHandler<[Post?]>) {
        let group = DispatchGroup()
        var posts: [Post?] = .init(repeating: nil, count: inputs.count)

        for (index, input) in inputs.enumerated() {
            group.enter()
            api.request(.createMyBlogPost(blog.id, input), to: Post.self) { result in
                if case let .success(model) = result {
                    posts[index] = model
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            handler(.success(posts))
        }
    }
}
