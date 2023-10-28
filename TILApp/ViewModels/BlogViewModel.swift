final class BlogViewModel {
    static let shared: BlogViewModel = .init()
    private init() {}

    private(set) var blogs: [Blog] = []

    func load(onSuccess: (([Blog]) -> Void)? = nil, onError: ((Error) -> Void)? = nil) {
        APIService.shared.request(.getMyBlogs, model: [Blog].self) { [weak self] model in
            guard let self else { return }
            blogs = model
            onSuccess?(blogs)
        } onError: { error in
            onError?(error)
        }
    }

    func create(_ input: CreateBlogInput, onSuccess: (([Blog]) -> Void)? = nil, onError: ((Error) -> Void)? = nil) {
        APIService.shared.request(.createBlog(input), model: Blog.self) { [weak self] model in
            guard let self else { return }
            blogs.append(model)
            onSuccess?(blogs)
        } onError: { error in
            onError?(error)
        }
    }

    func update(
        _ blog: Blog,
        _ input: UpdateBlogInput,
        onSuccess: (([Blog]) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        APIService.shared.request(.updateBlog(blog.id, input), model: Blog.self) { [weak self] model in
            guard let self else { return }
            if let index = (blogs.firstIndex { $0.id == blog.id }) {
                blogs[index] = model
            }
            onSuccess?(blogs)
        } onError: { error in
            onError?(error)
        }
    }

    func delete(_ blog: Blog, onSuccess: (([Blog]) -> Void)? = nil, onError: ((Error) -> Void)? = nil) {
        APIService.shared.request(.deleteBlog(blog.id)) { [weak self] _ in
            guard let self else { return }
            if let index = (blogs.firstIndex { $0.id == blog.id }) {
                blogs.remove(at: index)
            }
            onSuccess?(blogs)
        } onError: { error in
            onError?(error)
        }
    }

    // TODO: 다 정리되면 위쪽으로 옮기기
    private(set) var keywords: [KeywordInput] = []

    func clearKeywords() {
        keywords = []
    }

    func addKeyword(_ keyword: KeywordInput) {
        keywords.append(keyword)
    }

    func updateKeyword(_ index: Int, _ keyword: KeywordInput) {
        keywords[index] = keyword
    }

    func removeKeyword(index: Int) {
        keywords.remove(at: index)
    }

    func hasKeyword(_ keywordToCheck: String) -> Bool {
        return keywords.contains { $0.keyword == keywordToCheck }
    }
}
