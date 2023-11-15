import Dispatch
import Foundation

protocol CommunityViewModelDelegate: AnyObject {
    func itemsUpdated(_ viewModel: CommunityViewModel, updatedIndexPaths: [IndexPath])
    func itemsUpdated(_ viewModel: CommunityViewModel, atIndexPath: IndexPath)
    func itemsUpdated(_ viewModel: CommunityViewModel, items: [CommunityPost], range: Range<Int>)
    func errorOccurred(_ viewModel: CommunityViewModel, error: String)
}

final class CommunityViewModel: ViewModel {
    static var shared: CommunityViewModel = .init()
    static func reset() { shared = .init() }
    private init() {}

    weak var delegate: CommunityViewModelDelegate?

    typealias Handler = APIHandler<[CommunityPost]>

    private let api = APIService.shared

    private(set) var initialized: Bool = false
    private(set) var loading: Bool = false
    private(set) var fetching: Bool = false
    private(set) var searching: Bool = false
    private(set) var refreshing: Bool = false
    private(set) var completed: Bool = false

    private var nextCursor: Int?
    private var query: String?

    private(set) var posts: [CommunityPost] = []
    private var cache: [CommunityPost] = []

    func load(_ handler: Handler? = nil) {
        Task {
            loading = false
            await _load(limit: 10, desc: true) { [unowned self] result in
                if case .success(let posts) = result {
                    cache = posts
                }
                handler?(result)
            }
            loading = true
            initialized = true
        }
    }

    func reload() {
        posts = cache
        completed = false
        nextCursor = nil
        query = nil
    }

    func search(query: String, _ handler: Handler? = nil) {
        guard initialized else { return }
        Task {
            searching = true
            nextCursor = nil
            completed = false
            self.query = query
            await _load(
                limit: 10,
                desc: true,
                handler
            )
            searching = false
        }
    }

    func refresh(_ handler: Handler? = nil) {
        guard initialized else { return }
        Task {
            refreshing = true
            nextCursor = nil
            completed = false
            await _load(
                limit: 10,
                desc: true,
                handler
            )
            refreshing = false
        }
    }

    func loadMore(_ handler: Handler? = nil) {
        guard initialized, !completed else { return }
        Task {
            fetching = false
            await _load(
                next: true,
                limit: 5,
                desc: true,
                handler
            )
            fetching = true
        }
    }

    func _load(
        next: Bool = false,
        limit: Int? = nil,
        desc: Bool? = nil,
        _ handler: Handler? = nil
    ) async {
        do {
            let newPosts = try await api.request(.getCommunityPosts(.init(
                q: query,
                limit: limit,
                cursor: next ? nextCursor : nil,
                sort: desc == true ? .desc : .asc
            )), to: [CommunityPost].self)

            DispatchQueue.main.async { [unowned self] in
                if next {
                    let startIndex = posts.count
                    let endIndex = startIndex + newPosts.count
                    posts.append(contentsOf: newPosts)
                    delegate?.itemsUpdated(self, items: newPosts, range: startIndex ..< endIndex)
                } else {
                    posts = newPosts
                    delegate?.itemsUpdated(self, items: newPosts, range: 0 ..< newPosts.count)
                }
                nextCursor = newPosts.last?.id
                completed = nextCursor == nil && !posts.isEmpty
                handler?(.success(posts))
            }
        } catch APIError.error(let message) {
            delegate?.errorOccurred(self, error: message)
            handler?(.failure(.error(message)))
        } catch {
            let message = "알 수 없는 에러가 발생했습니다."
            delegate?.errorOccurred(self, error: message)
            handler?(.failure(.error(message)))
        }
    }

    func togglePostLikeState(
        _ currentLiked: Bool,
        of postId: Int,
        _ handler: @escaping (_ liked: Bool) -> Void
    ) {
        Task {
            let post = try? await APIService.shared.request(
                currentLiked ? .unlikePost(postId) : .likePost(postId),
                to: Post.self
            )
            DispatchQueue.main.sync {
                guard let post else { handler(currentLiked); return }
                if let index = posts.firstIndex(where: { $0.id == postId }) {
                    let oldPost = posts[index]
                    posts[index] = .init(
                        id: oldPost.id,
                        title: oldPost.title,
                        content: oldPost.content,
                        url: oldPost.url,
                        tags: oldPost.tags,
                        user: oldPost.user,
                        liked: post.liked,
                        publishedAt: oldPost.publishedAt
                    )
                }
                handler(post.liked)
            }
        }
    }

    func updatePosts(forUser updatedUser: User) {
        var updatedIndexPaths: [IndexPath] = []

        for (index, post) in posts.enumerated() where post.user.id == updatedUser.id {
            let updatedPost = CommunityPost(
                id: post.id, title: post.title, content: post.content,
                url: post.url, tags: post.tags, user: updatedUser,
                liked: post.liked, publishedAt: post.publishedAt
            )
            posts[index] = updatedPost
            updatedIndexPaths.append(IndexPath(row: index, section: 0))
        }

        delegate?.itemsUpdated(self, updatedIndexPaths: updatedIndexPaths)
    }
    
    func updatePosts(forPost postId: Int) {
        if let index = posts.firstIndex(where: { $0.id == postId }) {
            let indexPath = IndexPath(row: index, section: 0)
            delegate?.itemsUpdated(self, atIndexPath: indexPath)
        }
    }
}
