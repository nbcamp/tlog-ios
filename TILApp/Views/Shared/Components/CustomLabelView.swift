//
//  CustomLabelView.swift
//  TILApp
//
//  Created by 이재희 on 10/27/23.
//

import FlexLayout
import PinLayout
import Then
import UIKit

class CustomLabelView: UIView {
    private let nicknameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
    }

    private let dateLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = .systemGray2
    }

    private let height: CGFloat = 67
    var componentSize: CGSize {
        return CGSize(width: frame.width, height: height)
    }

    var nicknameText: String {
        get { nicknameLabel.text ?? "" }
        set { nicknameLabel.text = newValue }
    }

    var dateText: String {
        get { dateLabel.text ?? "" }
        set { dateLabel.text = newValue }
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
        flex.justifyContent(.center).define {
            $0.addItem(nicknameLabel)
            $0.addItem(dateLabel).marginTop(2)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        pin.width(100%).height(height)
        flex.layout()
    }
}
