struct Post: Codable {
    let id: Int
    let userId: Int
    let title: String
    let description: String
    let url: String
    let rss: String
    let publishedAt: Unixtime
    let createdAt: Unixtime
    let updatedAt: Unixtime

    enum CodingKeys: String, CodingKey {
        case id, title, description, url, rss
        case userId = "user_Id"
        case publishedAt = "published_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
