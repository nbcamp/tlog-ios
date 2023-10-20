//
//  BlogRegisterViewController.swift
//  TILApp
//
//  Created by 이재희 on 10/20/23.
//

import FlexLayout
import PinLayout
import UIKit

class BlogRegisterViewController: UIViewController {
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
    ]

    // TODO: 유효성 검증 로직 작성하기
    private lazy var blogNameTextField = CustomTextFieldViewWithValidation().then {
        $0.titleText = "블로그 이름"
        $0.placeholder = "블로그 이름을 입력해주세요"
        view.addSubview($0)
    }

    private lazy var blogURLTextField = CustomTextFieldViewWithValidation().then {
        $0.titleText = "블로그 주소"
        $0.placeholder = "블로그 주소를 입력해주세요"
        view.addSubview($0)
    }

    private lazy var blogRSSTextField = CustomTextFieldViewWithValidation().then {
        $0.titleText = "블로그 RSS 주소"
        $0.placeholder = "블로그 RSS 주소를 입력해주세요"
        view.addSubview($0)
    }

    private lazy var tagHeader = CustomTagHeaderView().then {
        view.addSubview($0)
    }

    private lazy var rootFlexContainer = UIView().then { root in
        root.flex.define {
            for (name, tags) in tagData {
                let customTagView = CustomTagView()
                customTagView.labelText = name
                customTagView.tags = tags
                $0.addItem(customTagView).marginTop(10)
            }
        }
        view.addSubview(root)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        blogNameTextField.pin.top(view.pin.safeArea).marginTop(10)
        blogURLTextField.pin.top(to: blogNameTextField.edge.bottom).marginTop(5)
        blogRSSTextField.pin.top(to: blogURLTextField.edge.bottom).marginTop(5)
        tagHeader.pin.top(to: blogRSSTextField.edge.bottom).marginTop(5)

        rootFlexContainer.pin.top(to: tagHeader.edge.bottom).bottom().width(100%)
        for view in rootFlexContainer.subviews {
            print(view)
        }
        rootFlexContainer.flex.layout()

    }
}
