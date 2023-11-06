//
//  RssViewModel.swift
//  TILApp
//
//  Created by 정동교 on 10/31/23.
//

import Foundation
import XMLCoder
/*
 세트의 장점 중복값을 허용 안함

 import Foundation

 let now = Date()
 let calendar = Calendar.current

 let components = calendar.dateComponents([.year, .month, .day], from: now)
 if let dateWithoutTime = calendar.date(from: components) {
     print(dateWithoutTime)
 }
 */

final class RssViewModel {
    // 더미데이터 나중에 서버에서 받아오는 데이터로 바뀔예정
    // 블로그 id랑 주소도 나중에 생성
    let dateFormatter = DateFormatter()
    static let shared: RssViewModel = .init()
    private init() {}
    private(set) var rss: RSS?
    private(set) var rssPostData: [Date: [RssPostData]] = [:]
    // 테이블뷰에 보여줄 데이터
    // 사용자가 미국? 날짜가 바뀌는 문제가 만들어짐
    // 딕셔너리 형태가 게시물 마다 만들어주는게 맞다
    // 서버와의 통신? 줄때는 형식이 다르다 그럼 결국 이건

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
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss z"
//        dateFormatter.locale = Locale(identifier: "en_US")
        var rssGetData: [RssPostData]
        guard let rssChannelPost = rss!.channel?.posts else { return }

        rssGetData = rssChannelPost.enumerated().map { index, indexData in
            // pubDate 관련 변수

            var postTitle = indexData.title ?? ""
            var postUrl = indexData.link ?? ""
            var postPublishedAt = Date()

            // title 데이터 가공
            if let convertTitle = indexData.title {
                postTitle = convertTitle
            }
            // pubDate 데이터 가공
            if let convertDate = indexData.pubDate {
                postPublishedAt = convertDate
            }

            // link 데이터 가공
            if let convertLink = rss!.channel!.posts[index].link {
                let convertUrlString = replacingStr(data: convertLink)
                postUrl = convertUrlString
            }

            var content = indexData.content ?? indexData.contentEncoded

            if let unwrapContent = content {
                content = replacingStr(data: unwrapContent)
            }

            return .init(
                title: postTitle,
                content: content ?? "",
                url: postUrl,
                publishedAt: postPublishedAt
            )
        }
        // 여기서부터 데이터 수정이 들어가면 됨
        rssGetData = rssGetData.filter { filterIndex in
            dateFormatter.dateFormat = "yyyyMMdd"
            let convertDate = dateFormatter.date(from: dateFormatter.string(from: filterIndex.publishedAt))!
            var tagBool = false
            let dateMinus = timePlusDate(date: convertDate, dayPlus: -1)

            tag.map {
                // 키워드가 타이틀의 일부분에 들어있는지 확인해야 해서 contains 사용 어차피 문자열 내에서만 돌아감
                if filterIndex.title.contains($0) {
                    calendarPostDataSetArr.insert(convertDate)
                    rssPostData["allData"]!.append(filterIndex)
                    if rssPostData[dateFormatter.string(from: filterIndex.publishedAt)] == nil {
                        rssPostData[dateFormatter.string(from: filterIndex.publishedAt)] = [filterIndex]
                    } else {
                        rssPostData[dateFormatter.string(from: filterIndex.publishedAt)]?.append(filterIndex)
                    }
//                    Calendar.current.dateComponents([.day], from: convertDate, to: continueFirstDate!).day! != continueCountNum
                    if continueFirstDate == nil {
                        continueFirstDate = convertDate
                    } else if rssPostData[dateFormatter.string(from: filterIndex.publishedAt)] == nil {
                        continueFirstDate = convertDate
                    }
                    tagBool = true
                }
            }
            return tagBool
        }

        print(rssPostData)
    }

    func timePlusDate(date: Date, dayPlus: Int) -> Date {
        return Calendar.current.date(
            byAdding: .day,
            value: dayPlus,
            to: date
        )!
    }

    func replacingStr(data: String) -> String {
        return data.replacingOccurrences(of: "<[^>]+>|\t|\n|;|&nbsp", with: "", options: .regularExpression, range: nil)
    }
}
