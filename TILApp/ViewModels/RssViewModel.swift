//
//  RssViewModel.swift
//  TILApp
//
//  Created by 정동교 on 10/31/23.
//

import Foundation
import XMLCoder

final class RssViewModel {
    
    // 더미데이터
    var tag: [String] = ["일기", "마작"]
    
    static let shared: RssViewModel = .init()
    private init() {}
    private(set) var rss: RSS?
    private(set) var calendarTableData: [CreatePostInput2] = []
    private(set) var datesWithCat: [String] = []
    private(set) var descriptionStr: [CreatePostInput2] = []
    func respondData(urlString : String) {

        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url){ data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                do {
                    self.rss = try XMLDecoder().decode(RSS.self, from: data)
                    DispatchQueue.main.async { [self] in
                        var createPostData : [CreatePostInput2]
                        // rss 데이터 맵돌리기
                        createPostData = rss!.channel!.posts.enumerated().map{ (index,indexData) in
                            // pubDate 관련 변수

                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
                            dateFormatter.locale = Locale(identifier:"en_US")

                            var postTitle = indexData.title ?? ""
                            var postUrl = indexData.link ?? ""
                            var postPublishedAt : Date?

                            dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"

                            // title 데이터 가공
                            if let convertTitle = indexData.title{
                                postTitle = convertTitle
                            }

                            // pubDate 데이터 가공
                            if let convertDate = dateFormatter.date(from: indexData.pubDate!) {
                                postPublishedAt = convertDate
                            }

                            // link 데이터 가공
                            if let convertLink = rss!.channel!.posts[index].link {
                                let convertUrlString = convertLink.replacingOccurrences(of: "<[^>]+>|\t|\n", with: "", options: .regularExpression, range: nil)
                                postUrl = convertUrlString
                            }

                            var content = indexData.content ?? indexData.contentEncoded

                            if let unwrapContent = content {

                                content = unwrapContent.replacingOccurrences(of: "<[^>]+>|\t|\n|;|&nbsp", with: "", options: .regularExpression, range: nil)
                            }


                            return .init(
                                title: postTitle,
                                content: content ?? "",
                                url: postUrl,
                                publishedAt: postPublishedAt!
                            )
                        }
                        createPostData = createPostData.filter{ filterIndex in
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyyMMdd"
                            var dateStr = ""
                            var tagBool = false

                            let convertStr = dateFormatter.string(from: filterIndex.publishedAt)

                            dateStr = convertStr

                            tag.map {

                                if filterIndex.title.contains($0) {

                                    datesWithCat.map { catDate in
                                        if dateStr == catDate {
                                            datesWithCat = datesWithCat.filter { $0 != catDate }
                                        }
                                    }
                                    datesWithCat.append(dateStr)
                            
                                    datesWithCat.sort()
                                    
                                    descriptionStr.append(filterIndex)
                                    tagBool = true
                                }
                            }
                            return tagBool
                        }
                        calendarTableData = descriptionStr
                    }
                } catch {
                    print("Error parsing JSON response")
                }
            } else {
                print("에러에러에러에러")
            }
        }
        task.resume()
    }
}
