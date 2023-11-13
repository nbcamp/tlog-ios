import UIKit

class CustomKeywordView: UIView {
    private var keywords: [KeywordInput] = []

    func setKeywords(_ keywords: [KeywordInput], target: Any, tapSelector: Selector, deleteSelector: Selector) {
        self.keywords = keywords
        removeAllSubviews()
        if keywords.isEmpty {
            flex.alignItems(.center).define { flex in
                flex.addItem(UILabel().then {
                    $0.text = "불러올 게시글의 제목에 포함될 키워드와\n게시물에 적용할 태그를 작성해주세요!"
                    $0.numberOfLines = 0
                    $0.font = .boldSystemFont(ofSize: 14)
                    $0.textColor = .systemGray3
                }).marginTop(20)
            }.layout()
        } else {
            flex.define {
                for (index, keyword) in keywords.enumerated() {
                    let customTagView = CustomTagView()

                    customTagView.labelText = keyword.keyword
                    customTagView.tags = keyword.tags

                    $0.addItem(customTagView).marginTop(10)
                    customTagView.pin.horizontally()

                    let tapGestureRecognizer = ContextTapGestureRecognizer(target: target, action: tapSelector)
                    tapGestureRecognizer.context["index"] = index

                    customTagView.addGestureRecognizer(tapGestureRecognizer)
                    customTagView.isUserInteractionEnabled = true
                    customTagView.addTargetForButton(target: target, action: deleteSelector, for: .touchUpInside)
                }
            }
            flex.layout(mode: .adjustHeight)
        }
    }
}
