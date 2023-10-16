//
//  RegisterViewController.swift
//  TILApp
//
//  Created by Lee on 10/16/23.
//

import FlexLayout
import PinLayout
import UIKit

class RegisterViewController: UIViewController {
    let hiLabel = {
        let label = UILabel()
        label.text = "ooo님, 안녕하세요!"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.sizeToFit()
        return label
    }()

    let registerBlogLabel = {
        let label = UILabel()
        label.text = "블로그를 등록해주세요!✅"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.sizeToFit()
        return label
    }()

    let registerBlogButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.setTitle("블로그 등록하기", for: .normal)
        button.sizeToFit()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.cornerRadius = 8
        button.backgroundColor = .systemTeal
        button.setBackgroundImage(UIImage(named: "pressedButtonImage"), for: .highlighted)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setUpUI()
        registerBlogButton.addTarget(self, action: #selector(registerBlogButtonTapped), for: .touchUpInside)
    }

    func setUpUI() {
        view.addSubview(hiLabel)
        view.addSubview(registerBlogLabel)
        view.addSubview(registerBlogButton)

        hiLabel.pin.hCenter().vCenter(-15%)
        registerBlogLabel.pin.hCenter().vCenter(-10%)
        registerBlogButton.pin.left(7.5%).right(7.5%).center()
    }

    @objc func registerBlogButtonTapped() {
        print("블로그등록 페이지 뷰전환")
        let homeViewController = HomeViewController()

        navigationController?.pushViewController(homeViewController, animated: true)
    }
}
