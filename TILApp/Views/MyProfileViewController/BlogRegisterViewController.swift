//
//  BlogRegisterViewController.swift
//  TILApp
//
//  Created by 이재희 on 10/20/23.
//

import FlexLayout
import PinLayout
import UIKit

final class BlogRegisterViewController: UIViewController {
    let tagData: [(name: String, tags: [String])] = [
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

    private let contentScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }

    private let contentView = UIView()

    // TODO: 유효성 검증 로직 작성하기
    private lazy var blogNameTextField = CustomTextFieldViewWithValidation().then {
        $0.titleText = "블로그 이름"
        $0.placeholder = "블로그 이름을 입력해주세요"
        contentView.addSubview($0)
        $0.pin.size($0.componentSize)
    }

    private lazy var blogURLTextField = CustomTextFieldViewWithValidation().then {
        $0.titleText = "블로그 주소"
        $0.placeholder = "블로그 주소를 입력해주세요"
        contentView.addSubview($0)
        $0.pin.size($0.componentSize)
    }

    private lazy var blogRSSTextField = CustomTextFieldViewWithValidation().then {
        $0.titleText = "블로그 RSS 주소"
        $0.placeholder = "블로그 RSS 주소를 입력해주세요"
        contentView.addSubview($0)
        $0.pin.size($0.componentSize)
    }

    private lazy var tagHeader = CustomTagHeaderView().then {
        contentView.addSubview($0)
        $0.pin.size($0.componentSize)
    }

    private lazy var rootFlexContainer = UIView().then { root in
        root.flex.define {
            for (name, tags) in tagData {
                let customTagView = CustomTagView()
                customTagView.labelText = name
                customTagView.tags = tags
                $0.addItem(customTagView).marginTop(10)
                customTagView.pin.size(customTagView.componentSize)
            }
        }
        contentView.addSubview(root)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        view.addSubview(contentScrollView)
        contentScrollView.addSubview(contentView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        contentScrollView.pin.top(view.pin.safeArea).horizontally().bottom()
        contentView.pin.top(to: contentScrollView.edge.top).horizontally()

        blogNameTextField.pin.top().marginTop(10)
        blogURLTextField.pin.top(to: blogNameTextField.edge.bottom).marginTop(5)
        blogRSSTextField.pin.top(to: blogURLTextField.edge.bottom).marginTop(5)
        tagHeader.pin.top(to: blogRSSTextField.edge.bottom).marginTop(5)

        rootFlexContainer.pin.top(to: tagHeader.edge.bottom).bottom().width(100%)
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        for view in rootFlexContainer.subviews {
            view.pin.size(CGSize(width: contentView.frame.width, height: 67))
            print(view)
        }

        contentView.pin.top(to: contentScrollView.edge.top).horizontally().above(of: rootFlexContainer)

        // TODO: 높이 조절하기, 앱 백그라운드로 가면 rootFlexContainer 높이 달라지는 문제 해결하기
        let contentHeight = contentView.frame.maxY + rootFlexContainer.frame.height
        contentScrollView.contentSize = CGSize(width: contentView.frame.width, height: contentHeight)

        print(contentScrollView)
        print(contentView)
        print(blogRSSTextField)
        print(tagHeader)
        print(rootFlexContainer)
        print(contentHeight)
    }
}
