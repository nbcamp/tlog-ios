func toDictionary(from object: Any) -> [String: Any] {
    var result: [String: Any] = [:]
    let mirror = Mirror(reflecting: object)
    for (key, value) in mirror.children {
        guard let key else { continue }
        switch value {
        case Optional<Any>.none:
            continue
        case Optional<Any>.some(let value):
            result[key] = value
        default:
            result[key] = value
        }
    }
    return result
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
