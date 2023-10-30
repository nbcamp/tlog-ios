import UIKit

final class BlogRegisterViewController: UIViewController, UIGestureRecognizerDelegate {
    private let blogViewModel = BlogViewModel.shared

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
        $0.delegate = self
        contentView.addSubview($0)
    }

    private lazy var blogRSSTextField = CustomTextFieldViewWithValidation().then {
        $0.titleText = "블로그 RSS 주소"
        $0.placeholder = "블로그 RSS 주소를 입력해 주세요"
        $0.textFieldTag = 2
        $0.delegate = self
        contentView.addSubview($0)
    }

    private lazy var tagHeader = CustomTagHeaderView().then {
        contentView.addSubview($0)
        $0.pin.size($0.componentSize)
        $0.addTargetForButton(target: self, action: #selector(addTagButtonTapped), for: .touchUpInside)
    }

    @objc private func addTagButtonTapped() {
        navigationController?.pushViewController(EditTagViewController(), animated: true)
    }

    private lazy var rootFlexContainer = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "블로그 등록"
        view.backgroundColor = .systemBackground

        let doneButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = doneButton
        doneButton.isEnabled = false

        view.addSubview(contentScrollView)
        contentScrollView.addSubview(contentView)
        contentView.addSubview(rootFlexContainer)
    }

    // TODO: 프린트문 삭제
    @objc private func doneButtonTapped() {
        blogViewModel.create(.init(
            name: blogNameTextField.mainText,
            url: blogURLTextField.mainText,
            rss: blogRSSTextField.mainText,
            keywords: blogViewModel.keywords
        ), onSuccess: { [weak self] _ in
            guard let self = self else { return }
            print("블로그가 성공적으로 생성되었습니다.")
            navigationController?.popViewController(animated: true)
        }, onError: { error in
            print("블로그 생성 중 오류 발생: \(error)")
        })
        blogViewModel.clearKeywords()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.isNavigationBarHidden = false
        view.setNeedsLayout()
        
        updateDoneButtonState()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        rootFlexContainer.removeAllSubviews()

        rootFlexContainer.flex.define {
            for (index, keyword) in blogViewModel.keywords.enumerated() {
                let customTagView = CustomTagView()
                customTagView.labelText = keyword.keyword
                customTagView.tags = keyword.tags
                $0.addItem(customTagView).marginTop(10)
                customTagView.pin.size(customTagView.componentSize)

                let tapGestureRecognizer = ContextTapGestureRecognizer(target: self, action: #selector(customTagViewTapped(_:)))
                tapGestureRecognizer.context["index"] = index
                customTagView.addGestureRecognizer(tapGestureRecognizer)
                customTagView.isUserInteractionEnabled = true

                customTagView.addTargetForButton(target: self, action: #selector(deleteTagButtonTapped), for: .touchUpInside)
            }
        }

        contentScrollView.pin.top(view.pin.safeArea).horizontally().bottom()
        contentView.pin.top(to: contentScrollView.edge.top).horizontally()

        blogNameTextField.pin.horizontally().top().marginTop(10)
        blogURLTextField.pin.horizontally().top(to: blogNameTextField.edge.bottom).marginTop(5)
        blogRSSTextField.pin.horizontally().top(to: blogURLTextField.edge.bottom).marginTop(5)
        tagHeader.pin.top(to: blogRSSTextField.edge.bottom).marginTop(5)

        rootFlexContainer.pin.horizontally(20).top(to: tagHeader.edge.bottom).bottom().marginTop(-10)
        rootFlexContainer.flex.layout(mode: .adjustHeight)

        contentView.pin.top(to: contentScrollView.edge.top).horizontally().bottom(to: rootFlexContainer.edge.bottom)

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
           let index = rootFlexContainer.subviews.firstIndex(of: customTagView)
        {
            let keyword = blogViewModel.keywords[index]
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
                    self.blogViewModel.removeKeyword(index: index)
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
        if let url = URL(string: urlString) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    private func updateDoneButtonState() {
        navigationItem.rightBarButtonItem?.isEnabled = blogViewModel.keywords.count > 0 && blogNameTextField.isValid && blogURLTextField.isValid && blogRSSTextField.isValid
    }
}

// TODO: 키보드 url로 변경해주기
extension BlogRegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            if textField.tag == 0 {
                textField.resignFirstResponder()
                (contentView.viewWithTag(textField.tag + 1) as? UITextField)?.becomeFirstResponder()
            } else if textField.tag == 1 {
                textField.resignFirstResponder()
                (contentView.viewWithTag(textField.tag + 1) as? UITextField)?.becomeFirstResponder()
                // TODO: RSS로 자동변환 해주는 함수 연결하기
            } else if textField.tag == 2 {
                textField.resignFirstResponder()
            }
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 0 {
            if let currentText = textField.text, let range = Range(range, in: currentText) {
                let updatedText = currentText.replacingCharacters(in: range, with: string)

                if updatedText.isEmpty {
                    blogNameTextField.isValid = false
                    blogNameTextField.validationText = ""
                } else {
                    let isDuplicate = blogViewModel.hasBlogName(updatedText)
                    blogNameTextField.isValid = !isDuplicate
                    blogNameTextField.validationText = isDuplicate ? "이미 등록된 블로그 이름입니다." : "유효한 블로그 이름입니다."
                }
            }
        } else if textField.tag == 1 {
            if let currentText = textField.text, let range = Range(range, in: currentText) {
                let updatedText = currentText.replacingCharacters(in: range, with: string)

                if updatedText.isEmpty {
                    blogURLTextField.isValid = false
                    blogURLTextField.validationText = ""
                } else {
                    // URL 유효성 검사
                    if isValidURL(updatedText) {
                        blogURLTextField.isValid = true
                        blogURLTextField.validationText = "유효한 블로그 주소입니다."
                    } else {
                        blogURLTextField.isValid = false
                        blogURLTextField.validationText = "유효하지 않은 URL입니다."
                    }
                }
            }
        } else if textField.tag == 2 {
            if let currentText = textField.text, let range = Range(range, in: currentText) {
                let updatedText = currentText.replacingCharacters(in: range, with: string)

                if updatedText.isEmpty {
                    blogRSSTextField.isValid = false
                    blogRSSTextField.validationText = ""
                } else {
                    // TODO: RSS 유효성 검사?
                    if isValidURL(updatedText) {
                        blogRSSTextField.isValid = true
                        blogRSSTextField.validationText = "유효한 블로그 RSS 주소입니다."
                    } else {
                        blogRSSTextField.isValid = false
                        blogRSSTextField.validationText = "유효하지 않은 URL입니다."
                    }
                }
            }
        }

        updateDoneButtonState()

        return true
    }
}
