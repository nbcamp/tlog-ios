import Dispatch

final class CommunityViewModel {
    static let shared: CommunityViewModel = .init()
    private init() {}
    
    private var nextCursor: Int?
    private(set) var initialized: Bool = false
    private(set) var loading: Bool = false
    private(set) var searching: Bool = false
    private(set) var refreshing: Bool = false
    
    private(set) var cache: [CommunityPost] = []
    
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
            initialized = true
        }
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
            await _load(
                query: query,
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
        guard initialized else { return }
        Task {
            loading = false
            await _load(
                limit: 10,
                desc: true,
                onSuccess: onSuccess,
                onError: onError
            )
            loading = true
        }
    }

    func _load(
        query: String? = nil,
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

        DispatchQueue.main.async {
            switch result {
            case .success(let items): onSuccess?(items)
            case .failure(let error): onError?(error)
            }
        }
    }
}
