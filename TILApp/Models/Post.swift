import Foundation

struct Post: Codable {
    let id: Int
    let userId: Int
    let title: String
    let content: String
    let url: String
    let tags: [String]
    let publishedAt: Date
}

struct GetPostsQuery: Codable {
    let userId: Int?
    let q: String?
}

struct CreatePostInput: Codable {
    let title: String
    let content: String
    let url: String
    let publishedAt: Date
}

struct UpdatePostInput: Codable {
    let url: String?
    let tags: [String]?
}
