import UIKit

final class BlogEditViewController: UIViewController {
    var id: Int = 0 {
        didSet {
            blog = blogViewModel.getBlog(blogId: id)
            keywordInputViewModel.get(blog: blog)
        }
    }

    private lazy var blog: Blog = blogViewModel.getBlog(blogId: id)
    private let blogViewModel = BlogViewModel.shared
    private let keywordInputViewModel = KeywordInputViewModel.shared

    private let contentScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }

    private lazy var contentView = UIView()
    private lazy var customKeywordView = CustomKeywordView()

    private lazy var mainBlogButton = CustomLargeBorderButton().then {
        $0.variant = blog.main ? .primary : .normal
        contentView.addSubview($0)
        $0.addTarget(self, action: #selector(toMainButtonTapped), for: .touchUpInside)
    }

    // TODO: 완료 버튼 탭하면 해당 블로그 대표블로그로 설정 로직 추가하기
    @objc private func toMainButtonTapped() {
        mainBlogButton.variant = .primary
        navigationItem.rightBarButtonItem?.isEnabled = true
    }

    // TODO: 유효성 검증 로직 작성하기
    private lazy var blogNameTextField = CustomTextFieldViewWithValidation().then {
        $0.titleText = "블로그 이름"
        $0.mainText = blog.name
        $0.placeholder = "블로그 이름을 입력해주세요"
        $0.isValid = true
        $0.delegate = self
        contentView.addSubview($0)
    }

    private lazy var blogURLTextField = CustomTextFieldViewWithValidation().then {
        $0.titleText = "블로그 주소"
        $0.mainText = blog.url
        $0.readOnly = true
        contentView.addSubview($0)
    }

    private lazy var blogRSSTextField = CustomTextFieldViewWithValidation().then {
        $0.titleText = "블로그 RSS 주소"
        // TODO: RSS 주소로 수정하기
        $0.mainText = blog.rss
        $0.readOnly = true
        contentView.addSubview($0)
    }

    private lazy var deleteDescriptionLabel = UILabel().then {
        $0.text = "블로그 주소를 수정하기 위해선 삭제 후 새로 등록해야 합니다."
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textAlignment = .center
        $0.textColor = .systemGray3
        contentView.addSubview($0)
    }

    private lazy var deleteBlogButton = CustomLargeBorderButton().then {
        $0.setTitle(blog.main ? "메인 블로그는 삭제할 수 없습니다." : "블로그 삭제하기", for: .normal)
        $0.layer.borderColor = UIColor.systemRed.cgColor
        $0.setTitleColor(.systemRed, for: .normal)
        $0.isUserInteractionEnabled = !blog.main

        contentView.addSubview($0)
        $0.addTarget(self, action: #selector(deleteBlogButtonTapped), for: .touchUpInside)
    }

    @objc private func deleteBlogButtonTapped() {
        let alertController = UIAlertController(
            title: "블로그 삭제",
            message: "\n블로그를 삭제하시겠습니까?",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(
            title: "취소",
            style: .cancel,
            handler: nil
        )
        alertController.addAction(cancelAction)

        let deleteAction = UIAlertAction(
            title: "삭제",
            style: .destructive,
            handler: { [weak self] _ in
                guard let self else { return }
                blogViewModel.delete(blog: blog) { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        )
        alertController.addAction(deleteAction)

        present(alertController, animated: true, completion: nil)
    }

    private lazy var tagHeader = CustomTagHeaderView().then {
        contentView.addSubview($0)
        $0.addTargetForButton(target: self, action: #selector(addTagButtonTapped), for: .touchUpInside)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()

        title = "블로그 수정"
        view.backgroundColor = .systemBackground

        let doneButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = doneButton
        doneButton.isEnabled = false

        view.addSubview(contentScrollView)
        contentScrollView.addSubview(contentView)
        contentView.addSubview(customKeywordView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.setNeedsLayout()

        let blogKeywords = blog.keywords.map { KeywordInput(from: $0) }
        if blogKeywords != keywordInputViewModel.keywords {
            updateDoneButtonState()
        }
    }

    @objc private func doneButtonTapped() {
        blogViewModel.update(blog: blog, .init(
            name: blogNameTextField.mainText,
            main: mainBlogButton.variant == .primary,
            keywords: keywordInputViewModel.keywords
        )) { [weak self] result in
            guard let self else { return }
            if case .failure(let error) = result {
                // TODO: 에러처리
                debugPrint(#function, error)
                return
            }
            RssViewModel.shared.reload()
            navigationController?.popViewController(animated: true)
        }
    }

    private func updateDoneButtonState() {
        navigationItem.rightBarButtonItem?.isEnabled
            = keywordInputViewModel.keywords.count > 0 && blogNameTextField.isValid
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

        mainBlogButton.pin.top(contentView.pin.safeArea).marginTop(10)
        blogNameTextField.pin.horizontally().top(to: mainBlogButton.edge.bottom).marginTop(15)
        blogURLTextField.pin.horizontally().top(to: blogNameTextField.edge.bottom).marginTop(5)
        blogRSSTextField.pin.horizontally().top(to: blogURLTextField.edge.bottom).marginTop(5)
        deleteDescriptionLabel.pin.top(to: blogRSSTextField.edge.bottom).horizontally(20).height(25).marginTop(5)
        deleteBlogButton.pin.top(to: deleteDescriptionLabel.edge.bottom)

        tagHeader.pin.top(to: deleteBlogButton.edge.bottom).marginTop(20)

        customKeywordView.pin.horizontally(20).top(to: tagHeader.edge.bottom).bottom().marginTop(-10)
        customKeywordView.flex.layout(mode: .adjustHeight)

        contentView.pin.top(to: contentScrollView.edge.top).horizontally().bottom(to: customKeywordView.edge.bottom)

        contentScrollView.contentSize = CGSize(width: contentView.frame.width, height: contentView.frame.height)
    }

    @objc private func addTagButtonTapped() {
        navigationController?.pushViewController(EditTagViewController(), animated: true)
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
}

extension BlogEditViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            textField.resignFirstResponder()
        }
        return true
    }

    func textField(
        _ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String
    ) -> Bool {
        if let currentText = textField.text,
           let range = Range(range, in: currentText)
        {
            let updatedText = currentText.replacingCharacters(in: range, with: string)

            if updatedText.isEmpty {
                blogNameTextField.isValid = false
                blogNameTextField.validationText = ""
            } else if updatedText == blog.name {
                blogNameTextField.isValid = true
                blogNameTextField.validationText = ""
            } else {
                let isDuplicate = blogViewModel.hasBlogName(updatedText)
                blogNameTextField.isValid = !isDuplicate
                blogNameTextField.validationText = isDuplicate ? "이미 등록된 블로그 이름입니다." : "유효한 블로그 이름입니다."
            }

            updateDoneButtonState()
        }

        return true
    }
}
