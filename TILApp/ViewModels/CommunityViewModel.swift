import Dispatch

final class CommunityViewModel {
    static let shared: CommunityViewModel = .init()
    private init() {}

    @Published private(set) var initialized: Bool = false
    @Published private(set) var loading: Bool = false
    @Published private(set) var fetching: Bool = false
    @Published private(set) var searching: Bool = false
    @Published private(set) var refreshing: Bool = false
    @Published private(set) var completed: Bool = false

    private var nextCursor: Int? {
        didSet { completed = nextCursor == nil && !items.isEmpty }
    }

    private var query: String?

    private(set) var items: [CommunityPost] = []
    private var cache: [CommunityPost] = []

    func load(
        onSuccess: (([CommunityPost]) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        Task {
            loading = false
            await _load(
                limit: 10,
                desc: true,
                onSuccess: { [weak self] items in
                    self?.cache = items
                    onSuccess?(items)
                },
                onError: onError
            )
            loading = true
            completed = false
            initialized = true
        }
    }

    func reload() {
        items = cache
        completed = false
        query = nil
    }

    func search(
        query: String?,
        onSuccess: (([CommunityPost]) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        guard initialized else { return }
        Task {
            nextCursor = nil
            searching = true
            self.query = query
            await _load(
                limit: 10,
                desc: true,
                onSuccess: onSuccess,
                onError: onError
            )
            searching = false
        }
    }

    func refresh(
        onSuccess: (([CommunityPost]) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        guard initialized else { return }
        Task {
            nextCursor = nil
            refreshing = true
            await _load(
                limit: 10,
                desc: true,
                onSuccess: onSuccess,
                onError: onError
            )
            refreshing = false
        }
    }

    func loadMore(
        onSuccess: (([CommunityPost]) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        guard initialized, !completed else { return }
        Task {
            fetching = false
            await _load(
                next: true,
                limit: 5,
                desc: true,
                onSuccess: onSuccess,
                onError: onError
            )
            fetching = true
        }
    }

    func _load(
        next: Bool = false,
        limit: Int? = nil,
        desc: Bool? = nil,
        onSuccess: (([CommunityPost]) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) async {
        let result = await APIService.shared.request(
            .getCommunity(.init(
                q: query,
                limit: limit,
                cursor: nextCursor,
                desc: desc
            )),
            model: [CommunityPost].self
        )

        DispatchQueue.main.async { [unowned self] in
            switch result {
            case .success(let items):
                if next {
                    self.items.append(contentsOf: items)
                } else {
                    self.items = items
                }
                nextCursor = items.last?.post.id
                onSuccess?(items)
            case .failure(let error):
                onError?(error)
            }
        }
    }
}
