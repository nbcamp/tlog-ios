final class BlogViewModel: ViewModel {
    static var shared: BlogViewModel = .init()
    static func reset() { shared = .init() }
    private init() {}

    private(set) var blogs: [Blog] = []

    func load(_ handler: @escaping APIHandler<[Blog]>) {
        APIService.shared.request(.getMyBlogs, to: [Blog].self) { [unowned self] result in
            if case let .success(model) = result {
                self.blogs = model
            }
            handler(result)
        }
    }

    func create(_ input: CreateBlogInput, _ handler: @escaping APIHandler<Blog>) {
        APIService.shared.request(.createMyBlog(input), to: Blog.self) { [unowned self] result in
            if case let .success(model) = result {
                self.blogs.append(model)
            }
            handler(result)
        }
    }

    func update(blog: Blog, _ input: UpdateBlogInput, _ handler: @escaping APIHandler<Blog>) {
        let index = input.main == true ? (self.blogs.firstIndex { $0.main }) : nil
        APIService.shared.request(.updateMyBlog(blog.id, input), to: Blog.self) { [unowned self] result in
            if case let .success(model) = result {
                if model.main == true, let index {
                    let blog = self.blogs[index]
                    self.blogs[index] = .init(
                        id: blog.id,
                        name: blog.name,
                        url: blog.url,
                        rss: blog.rss,
                        main: false,
                        keywords: blog.keywords,
                        lastPublishedAt: blog.lastPublishedAt,
                        createdAt: blog.createdAt
                    )
                }
                if let index = (blogs.firstIndex(where: { $0.id == blog.id })) {
                    self.blogs[index] = model
                }
            }
            handler(result)
        }
    }

    func delete(blog: Blog, _ handler: @escaping APIHandler<Bool>) {
        APIService.shared.request(.deleteMyBlog(blog.id)) { [unowned self] _ in
            if let index = (blogs.firstIndex(where: { $0.id == blog.id })) {
                self.blogs.remove(at: index)
                handler(.success(true))
                return
            }
            handler(.success(false))
        }
    }

    func getBlog(blogId: Int) -> Blog {
        return self.blogs.first { $0.id == blogId }!
    }

    func hasBlogName(_ blogNameToCheck: String) -> Bool {
        return self.blogs.contains { $0.name == blogNameToCheck }
    }

    func hasBlogURL(_ url: String) -> Bool {
        return self.blogs.contains { $0.url == url }
    }

}
