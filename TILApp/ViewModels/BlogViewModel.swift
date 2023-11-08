final class BlogViewModel {
    static let shared: BlogViewModel = .init()
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

    func getLastPublishedAt(userId: Int, _ handler: @escaping (String) -> Void) {
        APIService.shared.request(.getUserBlogs(userId), to: [Blog].self) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(blogs):
                let validBlogs = blogs.filter { $0.lastPublishedAt != nil }
                if let lastPublishedBlog = validBlogs.max(by: { $0.lastPublishedAt! < $1.lastPublishedAt! }) {
                    let formattedDate = "TIL 마지막 작성일 | " + lastPublishedBlog.lastPublishedAt!.format("YYYY-MM-DD")
                    handler(formattedDate)
                } else {
                    handler("작성한 TIL이 없습니다.")
                }
            case .failure:
                handler("블로그 정보가 없습니다.")
            }
        }
    }
}
