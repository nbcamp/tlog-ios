//
//  CustomLargeBorderButton.swift
//  TILApp
//
//  Created by 이재희 on 10/27/23.
//

import FlexLayout
import PinLayout
import Then
import UIKit

class CustomLargeBorderButton: UIButton {
    private let height: CGFloat = 35
    var componentSize: CGSize {
        return CGSize(width: frame.width, height: height)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupButton() {
        backgroundColor = UIColor.white
        layer.borderWidth = 0.5
        layer.borderColor = UIColor(named: "AccentColor")?.cgColor
        layer.cornerRadius = 12
        setTitleColor(UIColor(named: "AccentColor"), for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pin.horizontally(20).height(height)
    }
}
