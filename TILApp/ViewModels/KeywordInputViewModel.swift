import Foundation

final class KeywordInputViewModel {
    static let shared: KeywordInputViewModel = .init()
    private init() {}
    
    private(set) var keywords: [KeywordInput] = []

    func clear() {
        keywords = []
    }
    
    func get(blog: Blog) {
        keywords = blog.keywords.map{ KeywordInput.init(from: $0) }
    }

    func add(keyword: KeywordInput) {
        keywords.append(keyword)
    }

    func update(index: Int, keyword: KeywordInput) {
        keywords[index] = keyword
    }

    func remove(index: Int) {
        keywords.remove(at: index)
    }

    func has(keywordToCheck: String) -> Bool {
        return keywords.contains { $0.keyword == keywordToCheck }
    }
}
