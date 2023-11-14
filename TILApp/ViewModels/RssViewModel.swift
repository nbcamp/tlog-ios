import Combine
import Foundation
import XMLCoder

final class RssViewModel {
    static let shared: RssViewModel = .init()
    private init() {}

    struct Post {
        let blog: Blog
        let title: String
        let content: String
        let url: String
        let tags: [String]
        let publishedAt: Date
    }

    private let calendar = Calendar.current
    private let rss = RssService.shared
    private let api = APIService.shared
    private var prepared = false

    private(set) var postsMap: [Date: [Post]] = [:]
    private(set) var postsByBlogMap: [Int: [Post]] = [:]
    private(set) var postsByMonthMap: [Date: [Post]] = [:]
    private(set) var allPosts: [Post] = []
    private(set) var startOfStreakDays: Date?
    @Published private(set) var loading = false

    var streakDays: Int? {
        guard let startOfStreakDays else { return nil }
        let components = calendar.dateComponents([.day], from: startOfStreakDays, to: Date())
        if let days = components.day { return days + 1 } else { return nil }
    }

    func prepare(_ completion: ((Bool) -> Void)? = nil) {
        if prepared { completion?(true); return }
        prepared = true

        postsMap = [:]
        postsByBlogMap = [:]
        postsByMonthMap = [:]
        allPosts = []
        startOfStreakDays = nil

        Task {
            let authUser = try await AuthViewModel.shared.sync()
            guard authUser.hasBlog else { completion?(false); return }

            loading = true
            do {
                let blogs = try await api.request(.getMyBlogs, to: [Blog].self)
                await prepareDatasets(blogs: blogs)
                findStartOfStreakDays()

                await sendPostsToServer()
                completion?(true)
            } catch {
                debugPrint(#function, error)
                completion?(false)
            }
            loading = false
        }
    }

    func reload(_ completion: ((Bool) -> Void)? = nil) {
        prepared = false
        prepare(completion)
    }

    func isDateInStreakDays(date: Date) -> Bool {
        guard let startOfStreakDays else { return false }
        return startOfStreakDays <= date && date <= .now
    }

    private func prepareDatasets(blogs: [Blog]) async {
        for blog in blogs {
            do {
                let posts = try await rss.loadDocument(url: blog.rss)
                for post in posts {
                    guard let keywordMap = (blog.keywords.first { post.title.contains($0.keyword) }) else { continue }
                    allPosts.append(.init(
                        blog: blog,
                        title: post.title,
                        content: post.content,
                        url: post.url,
                        tags: keywordMap.tags,
                        publishedAt: post.publishedAt
                    ))
                }
            } catch {
                debugPrint(#function, error)
            }
        }

        allPosts.sort { $0.publishedAt > $1.publishedAt }

        for post in allPosts {
            let startOfDay = post.publishedAt.startOfDay
            let startOfMonth = post.publishedAt.startOfMonth
            postsMap[startOfDay, default: []].append(post)
            postsByBlogMap[post.blog.id, default: []].append(post)
            postsByMonthMap[startOfMonth, default: []].append(post)
        }
    }

    private func sendPostsToServer() async {
        for (blogId, posts) in postsByBlogMap {
            for post in posts {
                do {
                    guard post.blog.lastPublishedAt == nil
                        || post.publishedAt > post.blog.lastPublishedAt! else { return }
                    _ = try await api.request(.createMyBlogPost(blogId, .init(
                        title: post.title,
                        content: post.content,
                        url: post.url,
                        publishedAt: post.publishedAt
                    )))
                } catch {
                    debugPrint(#function, error)
                }
            }
        }
    }

    private func findStartOfStreakDays() {
        guard !postsMap.isEmpty else { return }
        var startOfDate = Date().startOfDay
        for _ in 0 ..< allPosts.count {
            guard let posts = postsMap[startOfDate], !posts.isEmpty else { break }
            startOfStreakDays = startOfDate
            if let date = calendar.date(byAdding: .day, value: -1, to: startOfDate) {
                startOfDate = date
            } else {
                debugPrint("캘린더 연산 실패")
            }
        }
    }
}
