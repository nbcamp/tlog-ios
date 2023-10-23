struct Keyword: Codable {
    let keyword: String
    let tags: [String]
}

struct Blog: Codable {
    let id: Int
    let name: String
    let url: String
    let rss: String
    let primary: Bool
    let keywords: [Keyword]
    let createdAt: Unixtime

    enum CodingKeys: String, CodingKey {
        case id, name, url, rss, primary, keywords
        case createdAt = "created_at"
    }
}

struct CreateBlogInput: Codable {
    let name: String
    let url: String
    let rss: String
    let keywords: [Keyword]
}

struct UpdateBlogInput: Codable {
    let name: String?
    let primary: Bool?
    let keywords: [Keyword]?
}
