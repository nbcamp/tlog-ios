import UIKit

final class BlogRegisterViewController: UIViewController, UIGestureRecognizerDelegate {
    private let blogViewModel = BlogViewModel.shared

    private let contentScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }

    private let contentView = UIView()

    // TODO: 유효성 검증 로직 작성하기
    private lazy var blogNameTextField = CustomTextFieldViewWithValidation().then {
        $0.titleText = "블로그 이름"
        $0.placeholder = "블로그 이름을 입력해주세요"
        contentView.addSubview($0)
    }

    private lazy var blogURLTextField = CustomTextFieldViewWithValidation().then {
        $0.titleText = "블로그 주소"
        $0.placeholder = "블로그 주소를 입력해주세요"
        contentView.addSubview($0)
    }

    private lazy var blogRSSTextField = CustomTextFieldViewWithValidation().then {
        $0.titleText = "블로그 RSS 주소"
        $0.placeholder = "블로그 RSS 주소를 입력해주세요"
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

        view.addSubview(contentScrollView)
        contentScrollView.addSubview(contentView)
        contentView.addSubview(rootFlexContainer)
    }

    @objc private func doneButtonTapped() {
        // TODO: 저장하고 나서 clear하기
        blogViewModel.clearKeywords()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.isNavigationBarHidden = false
        view.setNeedsLayout()
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
                    self.view.setNeedsLayout()
                }
            )

            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)

            present(alertController, animated: true, completion: nil)
        }
    }
}
