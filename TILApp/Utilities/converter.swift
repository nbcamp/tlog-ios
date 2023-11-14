import Foundation

func toDictionary<T: Encodable>(from object: T, with encoder: JSONEncoder = JSONEncoder()) -> [String: Any] {
    guard let json = try? JSONSerialization.jsonObject(
        with: encoder.encode(object),
        options: .allowFragments
    ) as? [String: Any] else { return [:] }
    return json
}

func convertToRssUrl(from blogUrl: String) -> String? {
    var separateUrl = blogUrl.components(separatedBy: "https://").joined()
    separateUrl = separateUrl.components(separatedBy: "/rss").joined()
    separateUrl = separateUrl.components(separatedBy: "/feed").joined()
    let splitUrl = separateUrl.split(separator: "/")

    if splitUrl[0].contains("tistory.com") {
        return "https://" + splitUrl[0] + "/rss"
    } else if splitUrl[0].contains("naver.com") {
        return "https://" + "rss." + "blog.naver.com/" + splitUrl[1]
    } else if splitUrl[0].contains("velog.io") {
        return "https://" + "v2." + "velog.io/rss/" + splitUrl[1]
    } else if splitUrl[0].contains("medium.com") {
        return "https://" + "medium.com/feed/" + splitUrl[1]
    }
    return nil
}

func toDate(string: String, formats: [String]) -> Date? {
    let formatter = DateFormatter()
    for format in formats {
        formatter.dateFormat = format
        if let date = formatter.date(from: string) {
            return date
        }
    }
    return nil
}
