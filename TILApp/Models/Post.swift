struct Post: Codable {
    let id: Int
    let title: String
    let content: String
    let url: String
    let publishedAt: Unixtime

    enum CodingKeys: String, CodingKey {
        case id, title, content, url
        case publishedAt = "published_at"
    }
}

struct UpdatePostInput: Codable {
    let url: String?
    let tags: [String]?
}
