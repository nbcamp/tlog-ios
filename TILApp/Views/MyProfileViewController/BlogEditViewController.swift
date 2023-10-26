//
//  BlogEditViewController.swift
//  TILApp
//
//  Created by 이재희 on 10/19/23.
//

import Then
import UIKit

final class BlogEditViewController: UIViewController {
    var tagData: [(name: String, tags: [String])] = [
        ("[iOS]", ["TIL", "iOS", "Swift"]),
        ("[Swift]", ["TIL", "iOS", "Swift"]),
        ("[iOS]", ["TIL", "iOS", "Swift"]),
        ("[iOS]", ["TIL", "iOS", "Swift"]),
        ("[Swift]", ["TIL", "iOS", "Swift"]),
        ("[iOS]", ["TIL", "iOS", "Swift"]),
        ("[iOS]", ["TIL", "iOS", "Swift"]),
        ("[Swift]", ["TIL", "iOS", "Swift"]),
        ("[iOS]", ["TIL", "iOS", "Swift"]),
        ("[iOS]", ["TIL", "iOS", "Swift"]),
        ("[Swift]", ["TIL", "iOS", "Swift"]),
        ("[iOS]", ["TIL", "iOS", "Swift"]),
        ("[iOS]", ["TIL", "iOS", "Swift"]),
        ("[Swift]", ["TIL", "iOS", "Swift"]),
        ("[iOS]", ["TIL", "iOS", "Swift"]),
        ("[iOS]", ["TIL", "iOS", "Swift"]),
        ("[Swift]", ["TIL", "iOS", "Swift"]),
        ("[iOS]", ["TIL", "iOS", "Swift"]),
    ]

    var blogName: String?
    var blogURL: String?

    private let contentScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }

    private lazy var contentView = UIView()
    private lazy var rootFlexContainer = UIView()

    // TODO: 대표블로그인 경우 어떻게 보여줄지 로직 추가하기
    private lazy var mainBlogButton = CustomLargeBorderButton().then {
        $0.setTitle("대표 블로그로 설정하기", for: .normal)
        contentView.addSubview($0)
        $0.pin.size($0.componentSize)
    }

    // TODO: 유효성 검증 로직 작성하기
    private lazy var blogNameTextField = CustomTextFieldViewWithValidation().then {
        $0.titleText = "블로그 이름"
        if let blogName = blogName {
            $0.mainText = blogName
        }
        $0.placeholder = "블로그 이름을 입력해주세요"
        $0.validationText = "유효한 값입니다"
        contentView.addSubview($0)
        $0.pin.size($0.componentSize)
    }

    private lazy var blogURLTextField = CustomTextFieldViewWithValidation().then {
        $0.titleText = "블로그 주소"
        if let blogURL = blogURL {
            $0.mainText = blogURL
        }
        $0.placeholder = "블로그 주소를 입력해주세요"
        contentView.addSubview($0)
        $0.pin.size($0.componentSize)
    }

    private lazy var blogRSSTextField = CustomTextFieldViewWithValidation().then {
        $0.titleText = "블로그 RSS 주소"
        // TODO: RSS 주소로 수정하기
        if let blogURL = blogURL {
            $0.mainText = blogURL
        }
        $0.placeholder = "블로그 RSS 주소를 입력해주세요"
        contentView.addSubview($0)
        $0.pin.size($0.componentSize)
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

    @objc private func doneButtonTapped() {}

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        rootFlexContainer.removeAllSubviews()

        rootFlexContainer.flex.define {
            for (index, tag) in tagData.enumerated() {
                let customTagView = CustomTagView()
                customTagView.labelText = tag.name
                customTagView.tags = tag.tags
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
        blogNameTextField.pin.top(to: mainBlogButton.edge.bottom).marginTop(20)
        blogURLTextField.pin.top(to: blogNameTextField.edge.bottom).marginTop(5)
        blogRSSTextField.pin.top(to: blogURLTextField.edge.bottom).marginTop(5)
        deleteDescriotionLabel.pin.top(to: blogRSSTextField.edge.bottom).horizontally(20).height(25).marginTop(5)
        deleteBlogButton.pin.top(to: deleteDescriotionLabel.edge.bottom)

        tagHeader.pin.top(to: deleteBlogButton.edge.bottom).marginTop(20)

        rootFlexContainer.pin.horizontally(20).top(to: tagHeader.edge.bottom).bottom().marginTop(-10)
        rootFlexContainer.flex.layout(mode: .adjustHeight)

        contentView.pin.top(to: contentScrollView.edge.top).horizontally().bottom(to: rootFlexContainer.edge.bottom)

        contentScrollView.contentSize = CGSize(width: contentView.frame.width, height: contentView.frame.height)
    }

    @objc private func addTagButtonTapped() {
        navigationController?.pushViewController(EditTagViewController(), animated: false)
    }

    @objc private func customTagViewTapped(_ sender: ContextTapGestureRecognizer) {
        if let index = sender.context["index"] as? Int {
            print(index, tagData[index])
            let editTagViewController = EditTagViewController()
            editTagViewController.selectedIndex = index
            editTagViewController.content = tagData[index]

            navigationController?.pushViewController(editTagViewController, animated: true)
        }
    }

    @objc private func deleteTagButtonTapped(_ sender: UIButton) {
        if let customTagView = sender.superview as? CustomTagView,
           let index = rootFlexContainer.subviews.firstIndex(of: customTagView)
        {
            let tag = tagData[index]
            let alertController = UIAlertController(
                title: "태그 삭제",
                message: "\n\(tag.name)\n\(tag.tags.joined(separator: ", "))\n\n태그를 삭제하시겠습니까?",
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
                    self.tagData.remove(at: index)
                    self.view.setNeedsLayout()
                }
            )

            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)

            present(alertController, animated: true, completion: nil)
        }
    }
}
