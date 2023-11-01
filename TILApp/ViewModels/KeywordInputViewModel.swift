import Foundation

final class KeywordInputViewModel {
    static let shared: KeywordInputViewModel = .init()
    private init() {}
    
    private(set) var keywords: [KeywordInput] = []

    func clearKeywords() {
        keywords = []
    }
    
    func initKeywords(blogId: Int) {
        keywords = (BlogViewModel.shared.getBlog(blogId: blogId).keywords.map{ KeywordInput.init(from: $0) })
    }

    func addKeyword(_ keyword: KeywordInput) {
        keywords.append(keyword)
    }

    func updateKeyword(_ index: Int, _ keyword: KeywordInput) {
        keywords[index] = keyword
    }

    func removeKeyword(index: Int) {
        keywords.remove(at: index)
    }

    func hasKeyword(_ keywordToCheck: String) -> Bool {
        return keywords.contains { $0.keyword == keywordToCheck }
    }
}
