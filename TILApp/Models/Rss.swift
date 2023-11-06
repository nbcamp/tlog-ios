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
    let pubDate: Date?
    let link: String?
    let contentEncoded: String?

    enum CodingKeys: String, CodingKey {
        case title, pubDate, link
        case contentEncoded = "content:encoded"
        case content = "description"
    }
}

// 애도 더미 CreatePostInput 에 맞춰 blogId가 생길 예정
struct RssPostData: Codable {
    let title: String
    let content: String
    let url: String
    let publishedAt: Date
}
