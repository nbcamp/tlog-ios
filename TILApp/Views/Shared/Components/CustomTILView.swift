//
//  CustomTILView.swift
//  TILApp
//
//  Created by 이재희 on 10/27/23.
//

import FlexLayout
import PinLayout
import Then
import UIKit

class CustomTILView: UIView {
    private let titleLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 18)
    }

    private let contentLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = .systemGray2
        $0.numberOfLines = 2
    }

    private let dateLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15)
        $0.textColor = UIColor(white: 0.33, alpha: 1.0)
        $0.textAlignment = .right
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

        addSubview(titleLabel)
        addSubview(contentLabel)
        addSubview(dateLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        pin.width(100%).height(85)

        titleLabel.pin
            .top(15)
            .left(20)
            .width(240)
            .height(22)

        contentLabel.pin
            .top(39)
            .left(21)
            .right(20)
            .height(36)

        dateLabel.pin
            .top(17)
            .right(20)
            .width(90)
            .height(20)
    }

    func setup(withTitle title: String, content: String, date: String) {
        titleLabel.text = title
        contentLabel.text = content
        dateLabel.text = date
    }

    func resizeText() {
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        dateLabel.font = UIFont.systemFont(ofSize: 14)
    }
}
