import Foundation

struct CommunityPost: Codable {
    let id: Int
    let title: String
    let content: String
    let url: String
    let tags: [String]
    let user: User
    let liked: Bool
    let publishedAt: Date
}

enum SortKind: String, Codable {
    case desc, asc
}

struct GetCommunityQuery: Codable {
    let q: String?
    let limit: Int?
    let cursor: Int?
    let sort: SortKind?
}
