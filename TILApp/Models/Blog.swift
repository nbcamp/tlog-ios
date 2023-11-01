import Foundation

struct Keyword: Codable {
    let keyword: String
    let tags: [String]
}

struct Blog: Codable {
    let id: Int
    let name: String
    let url: String
    let rss: String
    let main: Bool
    let keywords: [Keyword]
    let lastPublishedAt: Date?
    let createdAt: Date
}

struct CreateBlogInput: Codable {
    let name: String
    let url: String
    let rss: String
    let keywords: [KeywordInput]
}

struct UpdateBlogInput: Codable {
    let name: String?
    let keywords: [KeywordInput]?
}
