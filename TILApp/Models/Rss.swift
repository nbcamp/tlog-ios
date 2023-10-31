//
//  Rss.swift
//  TILApp
//
//  Created by 정동교 on 10/31/23.
//

import Foundation

struct RSS: Codable {
//    let to: String
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
struct CreatePostInput2: Codable {
    let title: String
    let content: String
    let url: String
    let publishedAt: Date
}
