//
//  CustomCommunityTILView.swift
//  TILApp
//
//  Created by 이재희 on 10/27/23.
//

import FlexLayout
import PinLayout
import Then
import UIKit

class CustomCommunityTILView: UIView {
    let userView = CustomUserView()
    let tilView = CustomTILView()

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

        tilView.resizeText()

        addSubview(tilView)
        addSubview(userView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        pin.width(100%).height(141)
        tilView.pin.top(54)
    }
}
