struct Pair: Codable {
    let keyword: String
    let tags: [String]
}

struct Blog: Codable {
    let id: Int
    let userId: Int
    let name: String
    let url: String
    let rss: String
    let pairs: [Pair]
    let createdAt: Unixtime
    let updatedAt: Unixtime

    enum CodingKeys: String, CodingKey {
        case id, name, url, rss, pairs
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
