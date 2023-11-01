final class BlogViewModel {
    static let shared: BlogViewModel = .init()
    private init() {}

    private(set) var blogs: [Blog] = []

    func load(
        onSuccess: ((_ blogs: [Blog]) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
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
        onSuccess: ((Blog) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil
    ) {
        APIService.shared.request(.updateBlog(blog.id, input), model: Blog.self) { [weak self] model in
            guard let self else { return }
            if let index = (blogs.firstIndex { $0.id == blog.id }) {
                blogs[index] = model
            }
            onSuccess?(model)
        } onError: { error in
            onError?(error)
        }
    }

    func delete(_ blog: Blog, onSuccess: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil) {
        APIService.shared.request(.deleteBlog(blog.id)) { [weak self] _ in
            guard let self else { return }
            if let index = (blogs.firstIndex { $0.id == blog.id }) {
                blogs.remove(at: index)
            }
            onSuccess?()
        } onError: { error in
            onError?(error)
        }
    }

    func setMainBlog(_ id: Int, onSuccess: (() -> Void)? = nil, onError: ((Error) -> Void)? = nil) {
        APIService.shared.request(.setMainBlog(id)) { [weak self] _ in
            guard let self = self else { return }
            updateMainBlog(id)
            onSuccess?()
        } onError: { error in
            onError?(error)
        }
    }

    func getBlog(blogId: Int) -> Blog {
        return blogs.first { $0.id == blogId }!
    }

    func hasBlogName(_ blogNameToCheck: String) -> Bool {
        return blogs.contains { $0.name == blogNameToCheck }
    }

    func hasBlogURL(_ url: String) -> Bool {
        return blogs.contains { $0.url == url }
    }

    func updateMainBlog(_ id: Int) {
        if let index = blogs.firstIndex(where: { $0.main }) {
            let oldBlog = blogs[index]
            let newBlog: Blog = .init(
                id: oldBlog.id,
                name: oldBlog.name,
                url: oldBlog.url,
                rss: oldBlog.rss,
                main: false,
                keywords: oldBlog.keywords,
                lastPublishedAt: oldBlog.lastPublishedAt,
                createdAt: oldBlog.createdAt
            )
            blogs[index] = newBlog
        }
        if let index = blogs.firstIndex(where: { $0.id == id }) {
            let oldBlog = blogs[index]
            let newBlog: Blog = .init(
                id: oldBlog.id,
                name: oldBlog.name,
                url: oldBlog.url,
                rss: oldBlog.rss,
                main: true,
                keywords: oldBlog.keywords,
                lastPublishedAt: oldBlog.lastPublishedAt,
                createdAt: oldBlog.createdAt
            )
            blogs[index] = newBlog
        }
    }
}
