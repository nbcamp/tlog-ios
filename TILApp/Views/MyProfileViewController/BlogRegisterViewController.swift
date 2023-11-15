import UIKit
import XMLCoder

final class BlogRegisterViewController: UIViewController, UIGestureRecognizerDelegate {
    var onRegistered: (() -> Void)?
    private var validated = false
    private var selectTextTag = 0
    private var beforeChar = ""
    private let blogViewModel = BlogViewModel.shared
    private let keywordInputViewModel = KeywordInputViewModel.shared

    private let contentScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }

    private let contentView = UIView()

    private lazy var blogNameTextField = CustomTextFieldViewWithValidation().then {
        $0.titleText = "블로그 이름"
        $0.placeholder = "블로그 이름을 입력해 주세요"
        $0.textFieldTag = 0
        $0.delegate = self
        contentView.addSubview($0)
    }

    private lazy var blogURLTextField = CustomTextFieldViewWithValidation().then {
        $0.titleText = "블로그 주소"
        $0.placeholder = "블로그 주소를 입력해 주세요"
        $0.textFieldTag = 1
        $0.keyboardType = .URL
        $0.delegate = self
        contentView.addSubview($0)
    }

    private lazy var blogRSSTextField = CustomTextFieldViewWithValidation().then {
        $0.titleText = "블로그 RSS 주소"
        $0.placeholder = "블로그 RSS 주소를 입력해 주세요"
        $0.textFieldTag = 2
        $0.keyboardType = .URL
        $0.delegate = self
        contentView.addSubview($0)
    }

    private lazy var tagHeader = CustomTagHeaderView().then {
        contentView.addSubview($0)
        $0.addTargetForButton(target: self, action: #selector(addTagButtonTapped), for: .touchUpInside)
    }

    @objc private func addTagButtonTapped() {
        navigationController?.pushViewController(EditTagViewController(), animated: true)
    }

    private lazy var customKeywordView = CustomKeywordView()

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()

        title = "블로그 등록"
        view.backgroundColor = .systemBackground

        let doneButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = doneButton
        doneButton.isEnabled = false

        view.addSubview(contentScrollView)
        contentScrollView.addSubview(contentView)
        contentView.addSubview(customKeywordView)
    }

    @objc private func doneButtonTapped() {
        blogViewModel.create(.init(
            name: blogNameTextField.mainText,
            url: blogURLTextField.mainText,
            rss: blogRSSTextField.mainText,
            keywords: keywordInputViewModel.keywords
        )) { [weak self] result in
            guard let self else { return }
            if case let .failure(error) = result {
                // TODO: 에러 처리
                debugPrint(#function, error)
                return
            }
            RssViewModel.shared.reload()
            onRegistered?()
            navigationController?.popViewController(animated: true)
        }
        keywordInputViewModel.clear()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
        view.setNeedsLayout()

        updateDoneButtonState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        customKeywordView.setKeywords(
            keywordInputViewModel.keywords,
            target: self, tapSelector: #selector(customTagViewTapped(_:)),
            deleteSelector: #selector(deleteTagButtonTapped(_:))
        )

        contentScrollView.pin.top(view.pin.safeArea).horizontally().bottom()
        contentView.pin.top(to: contentScrollView.edge.top).horizontally()

        blogNameTextField.pin.horizontally().top().marginTop(10)
        blogURLTextField.pin.horizontally().top(to: blogNameTextField.edge.bottom).marginTop(5)
        blogRSSTextField.pin.horizontally().top(to: blogURLTextField.edge.bottom).marginTop(5)
        tagHeader.pin.top(to: blogRSSTextField.edge.bottom).marginTop(5)

        customKeywordView.pin.horizontally(20).top(to: tagHeader.edge.bottom).bottom().marginTop(-10)
        customKeywordView.flex.layout(mode: .adjustHeight)

        contentView.pin.top(to: contentScrollView.edge.top).horizontally().bottom(to: customKeywordView.edge.bottom)

        contentScrollView.contentSize = CGSize(width: contentView.frame.width, height: contentView.frame.height)
    }

    @objc private func customTagViewTapped(_ sender: ContextTapGestureRecognizer) {
        if let index = sender.context["index"] as? Int {
            let editTagVC = EditTagViewController().then {
                $0.selectedIndex = index
                $0.variant = .update
            }

            navigationController?.pushViewController(editTagVC, animated: true)
        }
    }

    @objc private func deleteTagButtonTapped(_ sender: UIButton) {
        if let customTagView = sender.superview as? CustomTagView,
           let index = customKeywordView.subviews.firstIndex(of: customTagView)
        {
            let keyword = keywordInputViewModel.keywords[index]
            let alertController = UIAlertController(
                title: "태그 삭제",
                message: "\n\(keyword.keyword)\n\(keyword.tags.joined(separator: ", "))\n\n태그를 삭제하시겠습니까?",
                preferredStyle: .alert
            )

            let cancelAction = UIAlertAction(
                title: "취소",
                style: .cancel,
                handler: nil
            )

            let deleteAction = UIAlertAction(
                title: "삭제",
                style: .destructive,
                handler: { _ in
                    self.keywordInputViewModel.remove(index: index)
                    self.updateDoneButtonState()
                    self.view.setNeedsLayout()
                }
            )

            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)

            present(alertController, animated: true, completion: nil)
        }
    }

    private func isValidURL(_ urlString: String) -> Bool {
        guard !urlString.hasSuffix("/") else { return false }
        if let url = URL(string: urlString) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }

    private func updateDoneButtonState() {
        navigationItem.rightBarButtonItem?.isEnabled
            = blogRSSTextField.isValid
            && blogURLTextField.isValid && blogNameTextField.isValid && keywordInputViewModel.keywords.count > 0
    }

    private func urlEffectiveness(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        blogRSSTextField.isValid = false
        blogRSSTextField.validationText = "유효성 검사중...최대 10초 소요"
        let task = URLSession.shared.dataTask(with: url) { _, response, _ in
            if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                do {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        if validateBlogName(from: blogURLTextField.mainText, to: urlString) {
                            validated = true
                            updateBlogRSSField(with: urlString)
                            updateDoneButtonState()
                        } else {
                            validated = false
                            updateBlogRSSField(with: urlString)
                            updateDoneButtonState()
                        }
                    }
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    validated = false
                    updateBlogRSSField(with: urlString)
                    updateDoneButtonState()
                }
            }
        }
        task.resume()
    }
}

// TODO: 키보드 url로 변경해주기
extension BlogRegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        var rssText = blogRSSTextField.mainText
        var urlText = blogURLTextField.mainText
        var nameText = blogNameTextField.mainText
        guard let convertRss = convertToRssUrl(from: urlText) else { return false }
        guard let convertBlog = convertToBlogUrl(from: urlText) else { return false }

        if let currentText = textField.text {
            switch textField.tag {
            case 0:
                textField.resignFirstResponder()
                (contentView.viewWithTag(textField.tag + 1) as? UITextField)?.becomeFirstResponder()
                updateBlogNameField(with: nameText)
            case 1:
                textField.resignFirstResponder()
                (contentView.viewWithTag(textField.tag + 1) as? UITextField)?.becomeFirstResponder()
                updateBlogURLField(with: urlText)
                rssText = convertRss
                urlText = convertBlog

            case 2:
                textField.resignFirstResponder()
                urlEffectiveness(urlString: rssText)
            default:
                break
            }
        }

        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        let rssTextField = contentView.viewWithTag(2) as? UITextField
        if let currentText = rssTextField?.text, textField.tag == 0, selectTextTag == 2 {
            selectTextTag = textField.tag
            textField.resignFirstResponder()
            urlEffectiveness(urlString: currentText)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let currentText = textField.text {
            var rssText = blogRSSTextField.mainText
            var urlText = blogURLTextField.mainText
            var nameText = blogNameTextField.mainText
            guard let convertRss = convertToRssUrl(from: urlText) else { return }
            guard let convertBlog = convertToBlogUrl(from: urlText) else { return }

            switch textField.tag {
            case 0:
                updateBlogNameField(with: nameText)
            case 1:
                (contentView.viewWithTag(textField.tag + 1) as? UITextField)?.becomeFirstResponder()

                rssText = convertRss
                urlText = convertBlog

                selectTextTag = textField.tag + 1
                updateBlogURLField(with: urlText)
            case 2:
                urlEffectiveness(urlString: rssText)
                textField.resignFirstResponder()
            default:
                break
            }
        }
        updateDoneButtonState()
    }

    func blogNameChecker(string: String, currentText: String) {
        if beforeChar == string {
            blogNameTextField.isValid = false
            blogNameTextField.validationText = "입력창 조작중엔 등록이 불가능합니다.(최소 1자)"
            updateDoneButtonState()
        }
        beforeChar = string
        if string != "" {
            updateBlogNameField(with: currentText + string)
        }
    }

    func textField(
        _ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String
    ) -> Bool {
        let rssTextField = contentView.viewWithTag(2) as? UITextField

        if let currentText = textField.text {
            switch textField.tag {
            case 0:
                blogNameChecker(string: string, currentText: currentText)
            case 1:
                if string != "" {
                    if let rssUrl = convertToRssUrl(from: currentText + string) {
                        rssTextField?.text = rssUrl
                    }
                    updateBlogURLField(with: currentText + string)
                }
            case 2:
                if beforeChar == string {
                    blogRSSTextField.isValid = false
                    blogRSSTextField.validationText = "입력창 조작중엔 등록이 불가능합니다."
                    updateDoneButtonState()
                }
                beforeChar = string
                if string != "" {
                    urlEffectiveness(urlString: currentText + string)
                }
            default:
                break
            }
        }
        return true
    }

    func updateBlogNameField(with text: String) {
        if text.isEmpty || text.count < 1 {
            blogNameTextField.isValid = false
            blogNameTextField.validationText = "유효하지 않은 블로그 이름입니다.(최소 1자)"
        } else {
            let isDuplicate = blogViewModel.hasBlogName(text)
            blogNameTextField.isValid = !isDuplicate
            blogNameTextField.validationText = isDuplicate ? "이미 등록된 블로그 이름입니다." : "유효한 블로그 이름입니다."
            updateDoneButtonState()
        }
    }

    func updateBlogURLField(with text: String) {
        if text.isEmpty {
            blogURLTextField.isValid = false
            blogURLTextField.validationText = ""
        } else {
            // TODO: URL 유효성 검사
            if !blogRSSTextField.mainText.isEmpty || isValidURL(text) {
                let isDuplicate = blogViewModel.hasBlogURL(text)
                blogURLTextField.isValid = !isDuplicate
                blogURLTextField.validationText = isDuplicate ? "이미 등록된 블로그 URL입니다." : "유효한 블로그 URL입니다."
                updateDoneButtonState()
            } else {
                blogURLTextField.isValid = false
                blogURLTextField.validationText = "유효하지 않은 URL입니다."
            }
        }
    }

    func updateBlogRSSField(with text: String) {
        if text.isEmpty {
            blogRSSTextField.isValid = false
            blogRSSTextField.validationText = ""
        } else {
            // TODO: RSS 유효성 검사?
            if validated {
                blogRSSTextField.isValid = true
                blogRSSTextField.validationText = "유효한 RSS URL입니다."
                updateDoneButtonState()
            } else {
                blogRSSTextField.isValid = false
                blogRSSTextField.validationText = "유효하지 않은 URL입니다."
            }
        }
    }
}
