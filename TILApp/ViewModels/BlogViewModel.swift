final class BlogViewModel {
    static let shared: BlogViewModel = .init()
    private init() {}

    private(set) var blogs: [Blog] = []

    func load(_ handler: @escaping APIHandler<[Blog]>) {
        APIService.shared.request(.getMyBlogs, to: [Blog].self) { [unowned self] result in
            if case let .success(model) = result {
                blogs = model
            }
            handler(result)
        }
    }

    func create(_ input: CreateBlogInput, _ handler: @escaping APIHandler<Blog>) {
        APIService.shared.request(.createMyBlog(input), to: Blog.self) { [unowned self] result in
            if case let .success(model) = result {
                blogs.append(model)
            }
            handler(result)
        }
    }

    func update(blog: Blog, _ input: UpdateBlogInput, _ handler: @escaping APIHandler<Blog>) {
        APIService.shared.request(.updateMyBlog(blog.id, input), to: Blog.self) { [unowned self] result in
            if case let .success(model) = result {
                if let index = (blogs.firstIndex(where: { $0.id == blog.id })) {
                    blogs[index] = model
                }
            }
            handler(result)
        }
    }

    func delete(blog: Blog, _ handler: @escaping APIHandler<Bool>) {
        APIService.shared.request(.deleteMyBlog(blog.id)) { [unowned self] result in
            if let index = (blogs.firstIndex(where: { $0.id == blog.id })) {
                blogs.remove(at: index)
                handler(.success(true))
                return
            }
            handler(.success(false))
        }
    }

    func setMainBlog(blog: Blog, _ handler: @escaping APIHandler<Blog>) {
        APIService.shared.request(.setMyMainBlog(blog.id), to: Blog.self) { [unowned self] result in
            if case let .success(model) = result {
                updateMainBlog(blog: model)
            }
            handler(result)
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

    private func updateMainBlog(blog: Blog) {
        if let index = blogs.firstIndex(where: { $0.main }) {
            blogs[index] = blogs[index].withMain(false)
        }
        if let index = blogs.firstIndex(where: { $0.id == blog.id }) {
            blogs[index] = blog
        }
    }
}

extension Blog {
    func withMain(_ main: Bool) -> Blog {
        return Blog(
            id: self.id,
            name: self.name,
            url: self.url,
            rss: self.rss,
            main: main,
            keywords: self.keywords,
            lastPublishedAt: self.lastPublishedAt,
            createdAt: self.createdAt
        )
    }
}
