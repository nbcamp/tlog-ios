//  FollowViewController.swift
//  TILApp
//
//  Created by Lee on 10/19/23.
//

import FlexLayout
import PinLayout
import Then
import UIKit

final class ProfileEditViewController: UIViewController {
    private lazy var componentView = UIView().then {
        view.addSubview($0)
    }

    private lazy var editProfileImageView = UIImageView().then {
        $0.image = UIImage(systemName: "person.circle.fill")
        $0.tintColor = UIColor(named: "AccentColor")
//        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        $0.layer.cornerRadius = 50
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true

        var tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped(_:)))
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(tapGesture)
    }

    private lazy var editProfileButton = UIButton().then {
        $0.setImage(UIImage(systemName: "camera.circle"), for: .normal)
        $0.addTarget(self, action: #selector(editProfileButtonTapped), for: .touchUpInside)
        $0.backgroundColor = .white
    }

    private lazy var nicknameTextFieldView = CustomTextFieldViewWithValidation().then {
        $0.titleText = "유저 닉네임"
        $0.placeholder = "닉네임을 입력하세요"
        $0.validationText = ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(completeButtonTapped))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpUI()
    }

    private func setUpUI() {
        componentView.flex.direction(.column).marginTop(40).define { flex in
            flex.addItem().direction(.row).justifyContent(.center).define { flex in
                flex.addItem(editProfileImageView).width(100).height(100)
                flex.addItem(editProfileButton).position(.absolute).size(24).cornerRadius(12)
                    .bottom(8%).right(38%)
            }
            flex.addItem(nicknameTextFieldView).marginTop(10)
        }
        componentView.pin.top(view.pin.safeArea).bottom(50%).left(view.pin.safeArea).right(view.pin.safeArea)
        componentView.flex.layout()
    }

    @objc private func editProfileButtonTapped() {
        // TODO: 프로필사진 선택 로직
    }

    @objc private func profileImageViewTapped(_ sender: UITapGestureRecognizer) {
        // TODO: 프로필사진 선택 로직
    }

    @objc private func completeButtonTapped() {
        // TODO: 이미지,닉네임 저장 로직
        let myProfileViewController = MyProfileViewController()
        present(myProfileViewController, animated: true, completion: nil)
    }

    private func validateNickname() {
        // TODO: 닉네임 유효성 검사 로직
//        let nickname = nicknameTextFieldView.text
//        if {
//            print("통과")
//            nicknameTextFieldView.validationText = "유효한 닉네임입니다."
//        } else {
//            print("불통")
//            nicknameTextFieldView.validationText = "사용 불가능한 닉네임입니다.."
//        }
    }
}
