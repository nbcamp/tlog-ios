import Foundation

struct Post: Codable {
    let id: Int
    let userId: Int
    let title: String
    let content: String
    let url: String
    let tags: [String]
    let liked: Bool
    let publishedAt: Date
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
