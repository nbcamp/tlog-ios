import Foundation

func toDictionary<T: Encodable>(from object: T, with encoder: JSONEncoder = JSONEncoder()) -> [String: Any] {
    guard let json = try? JSONSerialization.jsonObject(
        with: encoder.encode(object),
        options: .allowFragments
    ) as? [String: Any] else { return [:] }
    return json
}

func splitStrConverter(str: String) -> [Substring] {
    var separateUrl = str.components(separatedBy: "https://").joined()
    separateUrl = separateUrl.components(separatedBy: "https:").joined()
    separateUrl = separateUrl.components(separatedBy: "http:").joined()
    separateUrl = separateUrl.components(separatedBy: "http://").joined()
    separateUrl = separateUrl.components(separatedBy: "/rss").joined()
    separateUrl = separateUrl.components(separatedBy: "/feed").joined()
    let splitUrl = separateUrl.split(separator: "/")
    return splitUrl
}

func convertToRssUrl(from blogUrl: String) -> String? {
    let splitRssUrl = splitStrConverter(str: blogUrl)
    if splitRssUrl.count > 0 {
        if splitRssUrl[0].contains("tistory.com") {
            return "https://" + splitRssUrl[0] + "/rss"
        } else if splitRssUrl[0].contains("naver.com"), splitRssUrl.count > 1 {
            return "https://" + "rss." + "blog.naver.com/" + splitRssUrl[1]
        } else if splitRssUrl[0].contains("velog.io"), splitRssUrl.count > 1 {
            return "https://" + "v2." + "velog.io/rss/" + splitRssUrl[1]
        } else if splitRssUrl[0].contains("medium.com"), splitRssUrl.count > 1 {
            return "https://" + "medium.com/feed/" + splitRssUrl[1]
        }
    }
    return blogUrl
}

func convertToBlogUrl(from blogUrl: String) -> String? {
    let splitUrl = splitStrConverter(str: blogUrl)
    if splitUrl.count > 0 {
        if splitUrl[0].contains("tistory.com") {
            return "https://" + splitUrl[0]
        } else if splitUrl[0].contains("naver.com"), splitUrl.count > 1 {
            return "https://" + "blog.naver.com/" + splitUrl[1]
        } else if splitUrl[0].contains("velog.io"), splitUrl.count > 1 {
            return "https://" + "velog.io/" + splitUrl[1]
        } else if splitUrl[0].contains("medium.com"), splitUrl.count > 1 {
            return "https://" + "medium.com/" + splitUrl[1]
        }
    }
    return blogUrl
}

func convertFromBlogToRss(from blogUrl: String, to rssUrl: String) -> Bool {
    let splitRssUrl = splitStrConverter(str: rssUrl)
    let splitBlogUrl = splitStrConverter(str: blogUrl)
    if splitRssUrl.count > 0, splitRssUrl.count > 0 {
        if splitRssUrl[0].contains("tistory.com") {
            return splitRssUrl[0] == splitBlogUrl[0]
        } else if splitRssUrl[0].contains("naver.com"), splitRssUrl.count > 1, splitRssUrl.count > 1 {
            return splitRssUrl[1] == splitBlogUrl[1]
        } else if splitRssUrl[0].contains("velog.io"), splitRssUrl.count > 1, splitRssUrl.count > 1 {
            return splitRssUrl[1] == splitBlogUrl[1]
        } else if splitRssUrl[0].contains("medium.com"), splitRssUrl.count > 1, splitRssUrl.count > 1 {
            return splitRssUrl[1] == splitBlogUrl[1]
        } else {
            return true
        }
    }
    return false
}

func toDate(string: String, formats: [String]) -> Date? {
    let formatter = DateFormatter()
    formatter.locale = .init(identifier: "en_US")
    for format in formats {
        formatter.dateFormat = format
        if let date = formatter.date(from: string) {
            return date
        }
    }
    return nil
}
