import UIKit

class CustomKeywordView: UIView {
    
    private var keywords: [KeywordInput] = []
    
    func setKeywords(_ keywords: [KeywordInput], target: Any, tapSelector: Selector, deleteSelector: Selector) {
        self.keywords = keywords
        self.removeAllSubviews()
        self.flex.define {
            for (index, keyword) in keywords.enumerated() {
                let customTagView = CustomTagView()
                customTagView.labelText = keyword.keyword
                customTagView.tags = keyword.tags
                $0.addItem(customTagView).marginTop(10)
                customTagView.pin.size(customTagView.componentSize)
                
                let tapGestureRecognizer = ContextTapGestureRecognizer(target: target, action: tapSelector)
                tapGestureRecognizer.context["index"] = index
                customTagView.addGestureRecognizer(tapGestureRecognizer)
                customTagView.isUserInteractionEnabled = true
                
                customTagView.addTargetForButton(target: target, action: deleteSelector, for: .touchUpInside)
            }
        }
        self.flex.layout(mode: .adjustHeight)
    }
}
