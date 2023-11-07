import Foundation

struct RSS: Codable {
    let channel: RSSChannel?
}

struct RSSChannel: Codable {
    let posts: [RSSPost]

    enum CodingKeys: String, CodingKey {
        case posts = "item"
    }
}

struct RSSPost: Codable {
    let title: String?
    let content: String?
    let pubDate: String?
    let link: String?
    let contentEncoded: String?

    enum CodingKeys: String, CodingKey {
        case title, pubDate, link
        case contentEncoded = "content:encoded"
        case content = "description"
    }
}

struct RssPostData: Codable {
    let title: String
    let content: String
    let url: String
    let publishedAt: Date
}
