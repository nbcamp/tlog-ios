//
//  CustomLargeButton.swift
//  TILApp
//
//  Created by 이재희 on 10/27/23.
//

import FlexLayout
import PinLayout
import Then
import UIKit

class CustomLargeButton: UIButton {
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
        backgroundColor = UIColor(named: "AccentColor")
        layer.cornerRadius = 12
        setTitleColor(UIColor(white: 1.0, alpha: 1.0), for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pin.horizontally(20).height(height)
    }
}