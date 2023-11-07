import Foundation
import XMLCoder

final class RssViewModel {
    let dateFormatter = DateFormatter()
    let calendar = Calendar.current
    static let shared: RssViewModel = .init()
    private init() {}
    private(set) var rss: RSS?
    private(set) var rssPostData: [Date: [RssPostData]] = [:]
    private(set) var rssPostAllData: [RssPostData] = []
    private(set) var continueFirstDate: Date?

    func respondData(urlString: String, tag: [String]) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                do {
                    self.rss = try XMLDecoder().decode(RSS.self, from: data)
                    self.creatRssData(tag: tag)

                } catch {
                    print("Error parsing JSON response")
                }
            } else {
                print("에러에러에러에러")
            }
        }
        task.resume()
    }

    func creatRssData(tag: [String]) {
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
        dateFormatter.locale = Locale(identifier: "en_US")
        guard let rssChannelPost = rss!.channel?.posts else { return }
        rssChannelPost.enumerated().forEach { index, indexData in

            var postTitle = indexData.title ?? ""
            var postUrl = indexData.link ?? ""
            var postPublishedAt = Date()

            if let convertDate = indexData.pubDate {
                postPublishedAt = dateFormatter.date(from: convertDate)!
            }

            if let convertLink = rss!.channel!.posts[index].link {
                let convertUrlString = replacingStr(data: convertLink)
                postUrl = convertUrlString
            }

            var content = indexData.content ?? indexData.contentEncoded
            var contentData = ""
            if let unwrapContent = content {
                content = replacingStr(data: unwrapContent)
                contentData = String(content!.prefix(20))
            }

            if let convertTitle = indexData.title {
                let apendData = RssPostData(title: postTitle,
                                            content: contentData,
                                            url: postUrl,
                                            publishedAt: postPublishedAt)
                postTitle = convertTitle
                tag.forEach {
                    if convertTitle.contains($0) {
                        rssPostAllData.append(apendData)
                        if rssPostData[utcTimeConvert(date: postPublishedAt)] == nil {
                            rssPostData[utcTimeConvert(date: postPublishedAt)] = [apendData]
                        } else {
                            rssPostData[utcTimeConvert(date: postPublishedAt)]!.append(apendData)
                        }
                    }
                }
            }
        }
        rssPostAllData.sort {
            $0.publishedAt.compare($1.publishedAt) == .orderedDescending
        }
        continuDate()
    }

    func continuDate() {
        var utcTime = utcTimeConvert(date: Date())
        if rssPostData[utcTime] != nil {
            for _ in rssPostAllData {
                continueFirstDate = utcTime
                utcTime = timePlusDate(date: utcTime, dayPlus: -1)
                if rssPostData[utcTime] == nil {
                    break
                }
            }
        }
    }

    func timePlusDate(date: Date, dayPlus: Int) -> Date {
        return Calendar.current.date(
            byAdding: .day,
            value: dayPlus,
            to: date
        )!
    }

    func utcTimeConvert(date: Date) -> Date {
        return calendar.date(from: calendar.dateComponents([.year, .month, .day], from: date))!
    }

    func replacingStr(data: String) -> String {
        return data.replacingOccurrences(of: "<[^>]+>|\t|\n|;|&nbsp", with: "", options: .regularExpression, range: nil)
    }
}
