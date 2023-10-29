import Dispatch

final class PostViewModel {
    static let shared: PostViewModel = .init()
    private init() {}

    func withPosts(
        by userId: Int,
        onSuccess: ((_ posts: [Post]) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        APIService.shared.request(
            .getPosts(.init(userId: userId, query: nil)),
            model: [Post].self,
            onSuccess: onSuccess,
            onError: onError
        )
    }

    func create(
        _ inputs: [CreatePostInput],
        onSuccess: ((_ posts: [Post?]) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        let group = DispatchGroup()
        var posts: [Post?] = .init(repeating: nil, count: inputs.count)

        for (index, input) in inputs.enumerated() {
            group.enter()
            APIService.shared.request(.createPost(input), model: Post.self) { model in
                posts[index] = model
                group.leave()
            } onError: { error in
                onError?(error)
                group.leave()
            }
        }

        group.notify(queue: .main) {
            onSuccess?(posts)
        }
    }

    func update(
        _ post: Post,
        _ input: UpdatePostInput,
        onSuccess: ((_ post: Post) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        APIService.shared.request(
            .updatePost(post.id, input),
            model: Post.self,
            onSuccess: onSuccess,
            onError: onError
        )
    }
}
