//
//  CustomUserView.swift
//  TILApp
//
//  Created by 이재희 on 10/27/23.
//

import FlexLayout
import PinLayout
import Then
import UIKit

class CustomUserView: UIView {
    private let button = CustomFollowButton()

    private let customLabelView = CustomLabelView()

    private let imageView = UIImageView().then {
        $0.backgroundColor = .systemGray5
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }

    var buttonTitle: String {
        get { button.titleLabel?.text ?? "" }
        set { button.setTitle(newValue, for: .normal) }
    }

    var nicknameText: String {
        get { customLabelView.nicknameText }
        set { customLabelView.nicknameText = newValue }
    }

    var dateText: String {
        get { customLabelView.dateText }
        set { customLabelView.dateText = newValue }
    }

    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        // backgroundColor = .systemBackground

        addSubview(imageView)
        addSubview(customLabelView)
        addSubview(button)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pin.width(100%).height(67)

        imageView.pin
            .vCenter()
            .left(10)
            .width(47)
            .height(47)

        customLabelView.pin
            .after(of: imageView)
            .marginLeft(10)

        button.pin
            .vCenter(-15)
            .right(100)

        imageView.layer.cornerRadius = imageView.bounds.size.width / 2.0
    }

    func setup(image: UIImage, nicknameText: String, contentText: String, buttonTitle: String) {
        imageView.image = image
        customLabelView.nicknameText = nicknameText
        customLabelView.dateText = contentText
        button.setTitle(buttonTitle, for: .normal)
    }
}
