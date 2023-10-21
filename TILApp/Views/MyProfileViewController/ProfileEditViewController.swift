//  FollowViewController.swift
//  TILApp
//
//  Created by Lee on 10/19/23.
//

import FlexLayout
import PinLayout
import Then
import UIKit

class ProfileEditViewController: UIViewController {
    private lazy var componentView = UIView().then {
        view.addSubview($0)
    }

    private lazy var editProfileImageView = UIImageView().then {
        $0.image = UIImage(named: "")
        $0.tintColor = .systemTeal
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 50
        $0.layer.borderColor = UIColor.systemTeal.cgColor
        $0.backgroundColor = .systemGray4
    }

    private lazy var editProfileButton = UIButton().then {
        $0.setImage(UIImage(systemName: "person.crop.circle"), for: .normal)
        $0.addTarget(self, action: #selector(editProfileButtonTapped), for: .touchUpInside)
        $0.backgroundColor = .white
    }

    private lazy var nicknameTextFieldView = CustomTextFieldView().then {
        $0.titleText = "유저 닉네임"
        $0.placeholder = "닉네임을 입력하세요"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(completeButtonTapped))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpUI()
        componentView.flex.layout()
    }

    private func setUpUI() {
        componentView.flex.direction(.column).marginTop(40).define { flex in
            flex.addItem().direction(.row).justifyContent(.center).define { flex in
                flex.addItem(editProfileImageView).width(100).height(100)
                flex.addItem(editProfileButton).position(.absolute).size(24).cornerRadius(12)
                    .bottom(5%).right(37%)
            }
            flex.addItem(nicknameTextFieldView).marginTop(10)
        }
        componentView.pin.top(view.pin.safeArea).bottom(50%).left(view.pin.safeArea).right(view.pin.safeArea)
    }

    @objc func editProfileButtonTapped() {
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
}
