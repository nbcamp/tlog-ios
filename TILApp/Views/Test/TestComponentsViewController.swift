//
//  TestComponentsViewController.swift
//  TILApp
//
//  Created by 이재희 on 10/27/23.
//

import FlexLayout
import PinLayout
import Then
import UIKit

class CustomComponentsViewController: UIViewController {
    private lazy var customLargeButton = CustomLargeButton().then {
        $0.setTitle("하이하이", for: .normal)
        view.addSubview($0)
    }

    private lazy var customFollowButton = CustomFollowButton().then {
        $0.setTitle("팔로우", for: .normal)
        view.addSubview($0)
    }

    private lazy var customUnfollowButton = CustomUnfollowButton().then {
        $0.setTitle("언팔로우", for: .normal)
        view.addSubview($0)
    }

    private lazy var customTextFieldView = CustomTextFieldViewWithValidation().then {
        $0.titleText = "하이하이하이하이하이하이"
        $0.placeholder = "뭐뭐를 입력해주세요."
        $0.validationText = "유효한 값입니다."
        view.addSubview($0)
    }

    private lazy var customLabelView = CustomLabelView().then {
        $0.nicknameText = "닉네임"
        $0.dateText = "2023-10-19"
        view.addSubview($0)
    }

    private lazy var customUserView = CustomUserView().then {
        $0.buttonTitle = "팔로우?"
        $0.nicknameText = "누구야"
        $0.dateText = "2023-10-192023-10-192023-10-19"
        view.addSubview($0)
    }

    private lazy var customTILView = CustomTILView().then {
        $0.setup(withTitle: "제목", content: "내용\n내용", date: "2023-10-17")
        view.addSubview($0)
    }

    private lazy var customCommunityTILView = CustomCommunityTILView().then {
        $0.userView.setup(image: UIImage(), nicknameText: "닉네임", contentText: "팔로워 11", buttonTitle: "팔로우")
        $0.tilView.setup(withTitle: "제목제목", content: "내용\n내용내용내용내용", date: "2023-10-19")
        view.addSubview($0)
    }

    private lazy var customBlogView = CustomBlogView().then {
        $0.blogNameText = "내 블로그으"
        $0.blogURLText = "http://djjjwjjjrhhhwj.com/sss"
        view.addSubview($0)
    }

    private lazy var customSegmentedControl = CustomSegmentedControl(items: ["작성한 글", "좋아요"]).then {
        view.addSubview($0)
    }

    private lazy var customTagView = CustomTagView().then {
        $0.labelText = "[TIL/Swift]"
        $0.tags = ["TIL", "iOS", "Swift", "내배캠", "으으으", "iOS", "Swift", "내배캠", "으으으"]
        view.addSubview($0)
    }

    private lazy var customTagHeaderView = CustomTagHeaderView().then {
        view.addSubview($0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGray6
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        customLargeButton.pin
            .top(view.pin.safeArea)
            .marginTop(15)

        customFollowButton.pin
            .hCenter()
            .top(to: customLargeButton.edge.bottom)
            .marginTop(15)

        customUnfollowButton.pin
            .hCenter()
            .top(to: customFollowButton.edge.bottom)
            .marginTop(15)

        customTextFieldView.pin
            .top(to: customUnfollowButton.edge.bottom)
            .marginTop(15)

        customUserView.pin
            .top(to: customTextFieldView.edge.bottom)
            .marginTop(15)

        customTILView.pin
            .top(to: customUserView.edge.bottom)
            .marginTop(15)

        customCommunityTILView.pin
            .top(to: customTILView.edge.bottom)
            .marginTop(15)

        customBlogView.pin
            .top(to: customCommunityTILView.edge.bottom)
            .marginTop(15)

//        customSegmentedControl.pin
//            .hCenter()
//            .top(to: customBlogView.edge.bottom)
//            .marginTop(15)

        customTagView.pin
            .top(to: customBlogView.edge.bottom)
            .margin(15)

        customTagHeaderView.pin
            .top(to: customTagView.edge.bottom)
            .margin(15)
    }
}
