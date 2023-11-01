import Foundation

struct KeywordInput: Codable, Equatable {
    var keyword: String
    var tags: [String]

    init(keyword: String, tags: [String]) {
        self.keyword = keyword
        self.tags = tags
    }

    init(from keyword: Keyword) {
        self.keyword = keyword.keyword
        self.tags = keyword.tags
    }
    
    static func == (lhs: KeywordInput, rhs: KeywordInput) -> Bool {
        return lhs.keyword == rhs.keyword && lhs.tags == rhs.tags
    }
}
