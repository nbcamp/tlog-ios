import Dispatch

protocol CommunityViewModelDelegate: AnyObject {
    func itemsUpdated(_ viewModel: CommunityViewModel, items: [CommunityPost], range: Range<Int>)
    func errorOccurred(_ viewModel: CommunityViewModel, error: Error)
}

final class CommunityViewModel {
    static let shared: CommunityViewModel = .init()
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

    private(set) var items: [CommunityPost] = []
    private var cache: [CommunityPost] = []

    func load(_ handler: Handler? = nil) {
        Task {
            loading = false
            await _load(limit: 10, desc: true) { [unowned self] result in
                if case .success(let items) = result {
                    cache = items
                }
                handler?(result)
            }
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

    func search(query: String,  _ handler: Handler? = nil) {
        guard initialized else { return }
        Task {
            searching = true
            self.query = query
            await _load(
                limit: 10,
                desc: true,
                handler
            )
            searching = false
            nextCursor = nil
            completed = false
        }
    }

    func refresh(_ handler: Handler? = nil) {
        guard initialized else { return }
        Task {
            refreshing = true
            await _load(
                limit: 10,
                desc: true,
                handler
            )
            refreshing = false
            nextCursor = nil
            completed = false
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
        let result = await api.request(.getCommunityPosts(.init(
            q: query,
            limit: limit,
            cursor: next ? nextCursor : nil,
            desc: desc)
        ), to: [CommunityPost].self)

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
                nextCursor = items.last?.id
                completed = nextCursor == nil && !items.isEmpty
                handler?(.success(items))
            case .failure(let error):
                delegate?.errorOccurred(self, error: error)
                handler?(.failure(error))
            }
        }
    }
}
