import Dispatch

protocol CommunityViewModelDelegate: AnyObject {
    func itemsUpdated(_ viewModel: CommunityViewModel, items: [CommunityPost], range: Range<Int>)
    func errorOccurred(_ viewModel: CommunityViewModel, error: Error)
}

final class CommunityViewModel {
    static let shared: CommunityViewModel = .init()
    private init() {}

    weak var delegate: CommunityViewModelDelegate?

    private(set) var initialized: Bool = false
    private(set) var loading: Bool = false
    private(set) var fetching: Bool = false
    private(set) var searching: Bool = false
    private(set) var refreshing: Bool = false
    private(set) var completed: Bool = false

    private var nextCursor: Int?
    private var query: String?

    private(set) var items: [CommunityPost] = []
    private var cache: [CommunityPost] = []

    func load(_ completion: ((Result<[CommunityPost], Error>) -> Void)? = nil) {
        Task {
            loading = false
            await _load(
                limit: 10,
                desc: true,
                { [weak self] result in
                    if let self, case .success(let items) = result {
                        cache = items
                    }
                    completion?(result)
                }
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
        _ completion: ((Result<[CommunityPost], Error>) -> Void)? = nil
    ) {
        guard initialized else { return }
        Task {
            searching = true
            self.query = query
            await _load(
                limit: 10,
                desc: true,
                completion
            )
            searching = false
            nextCursor = nil
            completed = false
        }
    }

    func refresh(_ completion: ((Result<[CommunityPost], Error>) -> Void)? = nil) {
        guard initialized else { return }
        Task {
            refreshing = true
            await _load(
                limit: 10,
                desc: true,
                completion
            )
            refreshing = false
            nextCursor = nil
            completed = false
        }
    }

    func loadMore(_ completion: ((Result<[CommunityPost], Error>) -> Void)? = nil) {
        guard initialized, !completed else { return }
        Task {
            fetching = false
            await _load(
                next: true,
                limit: 5,
                desc: true,
                completion
            )
            fetching = true
        }
    }

    func _load(
        next: Bool = false,
        limit: Int? = nil,
        desc: Bool? = nil,
        _ completion: ((Result<[CommunityPost], Error>) -> Void)? = nil
    ) async {
        let result = await APIService.shared.request(
            .getCommunity(.init(
                q: query,
                limit: limit,
                cursor: next ? nextCursor : nil,
                desc: desc
            )),
            model: [CommunityPost].self
        )

        DispatchQueue.main.async { [unowned self] in
            switch result {
            case .success(let newItems):
                if next {
                    let startIndex = items.count
                    let endIndex = startIndex + newItems.count
                    items.append(contentsOf: newItems)
                    delegate?.itemsUpdated(self, items: newItems, range: startIndex ..< endIndex)
                } else {
                    items = newItems
                    delegate?.itemsUpdated(self, items: newItems, range: 0 ..< newItems.count)
                }
                nextCursor = items.last?.post.id
                completed = nextCursor == nil && !items.isEmpty
                completion?(.success(items))
            case .failure(let error):
                delegate?.errorOccurred(self, error: error)
                completion?(.failure(error))
            }
        }
    }
}
