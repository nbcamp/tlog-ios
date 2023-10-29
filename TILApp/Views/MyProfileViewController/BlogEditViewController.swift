import UIKit

final class BlogEditViewController: UIViewController {
    var id: Int = 0 {
        didSet {
            blog = blogViewModel.getBlog(blogId: id)
            blogViewModel.initKeywords(blogId: id)
        }
    }

    private lazy var blog: Blog = blogViewModel.getBlog(blogId: id)
    private let blogViewModel = BlogViewModel.shared

    private let contentScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }

    private lazy var contentView = UIView()
    private lazy var rootFlexContainer = UIView()

    private lazy var mainBlogButton = CustomLargeBorderButton().then {
        $0.variant = blog.main ? .primary : .normal
        contentView.addSubview($0)
        $0.pin.size($0.componentSize)
        $0.addTarget(self, action: #selector(toMainButtonTapped), for: .touchUpInside)
    }

    // TODO: 완료 버튼 탭하면 해당 블로그 대표블로그로 설정 로직 추가하기
    @objc private func toMainButtonTapped() {
        mainBlogButton.variant = .primary
    }

    // TODO: 유효성 검증 로직 작성하기
    private lazy var blogNameTextField = CustomTextFieldViewWithValidation().then {
        $0.titleText = "블로그 이름"
        $0.mainText = blog.name
        $0.placeholder = "블로그 이름을 입력해주세요"
        $0.validationText = "유효한 값입니다"
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

    private lazy var deleteDescriotionLabel = UILabel().then {
        $0.text = "블로그 주소를 수정하기 위해선 삭제 후 새로 등록해야 합니다."
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textAlignment = .center
        $0.textColor = .systemGray3
        contentView.addSubview($0)
    }

    private lazy var deleteBlogButton = CustomLargeBorderButton().then {
        $0.setTitle("블로그 삭제하기", for: .normal)
        $0.layer.borderColor = UIColor.systemRed.cgColor
        $0.setTitleColor(.systemRed, for: .normal)

        contentView.addSubview($0)
        $0.pin.size($0.componentSize)
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
                blogViewModel.deleteBlog(blogId: id)
                blogViewModel.delete(blog)
                navigationController?.popViewController(animated: true)
            }
        )
        alertController.addAction(deleteAction)
        
        present(alertController, animated: true, completion: nil)
    }

    private lazy var tagHeader = CustomTagHeaderView().then {
        contentView.addSubview($0)
        $0.pin.size($0.componentSize)
        $0.addTargetForButton(target: self, action: #selector(addTagButtonTapped), for: .touchUpInside)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "블로그 수정"
        view.backgroundColor = .systemBackground

        let doneButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = doneButton

        view.addSubview(contentScrollView)
        contentScrollView.addSubview(contentView)
        contentView.addSubview(rootFlexContainer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.setNeedsLayout()
    }

    @objc private func doneButtonTapped() {}

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

        mainBlogButton.pin.top(contentView.pin.safeArea).marginTop(10)
        blogNameTextField.pin.horizontally().top(to: mainBlogButton.edge.bottom).marginTop(20)
        blogURLTextField.pin.horizontally().top(to: blogNameTextField.edge.bottom).marginTop(5)
        blogRSSTextField.pin.horizontally().top(to: blogURLTextField.edge.bottom).marginTop(5)
        deleteDescriotionLabel.pin.top(to: blogRSSTextField.edge.bottom).horizontally(20).height(25).marginTop(5)
        deleteBlogButton.pin.top(to: deleteDescriotionLabel.edge.bottom)

        tagHeader.pin.top(to: deleteBlogButton.edge.bottom).marginTop(20)

        rootFlexContainer.pin.horizontally(20).top(to: tagHeader.edge.bottom).bottom().marginTop(-10)
        rootFlexContainer.flex.layout(mode: .adjustHeight)

        contentView.pin.top(to: contentScrollView.edge.top).horizontally().bottom(to: rootFlexContainer.edge.bottom)

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
           let index = rootFlexContainer.subviews.firstIndex(of: customTagView)
        {
            let tag = blogViewModel.keywords[index]
            let alertController = UIAlertController(
                title: "태그 삭제",
                message: "\n\(tag.keyword)\n\(tag.tags.joined(separator: ", "))\n\n태그를 삭제하시겠습니까?",
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
