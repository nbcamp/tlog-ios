//
//  CustomTextFieldViewWithValidation.swift
//  TILApp
//
//  Created by 이재희 on 10/27/23.
//

import FlexLayout
import PinLayout
import Then
import UIKit

class CustomTextFieldViewWithValidation: UIView {
    var componentSize: CGSize {
        return CGSize(width: frame.width, height: height)
    }

    var titleText: String {
        get { customTextFieldView.titleText }
        set { customTextFieldView.titleText = newValue }
    }

    var placeholder: String {
        get { customTextFieldView.placeholder }
        set { customTextFieldView.placeholder = newValue }
    }

    var mainText: String {
        get { customTextFieldView.mainText }
        set { customTextFieldView.mainText = newValue }
    }

    var validationText: String {
        get { validationLabel.text ?? "" }
        set { validationLabel.text = newValue }
    }

    var readOnly: Bool = false {
        didSet {
            customTextFieldView.readOnly = readOnly
        }
    }

    private let customTextFieldView = CustomTextFieldView()

    private let validationLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 11, weight: .light)
        $0.textColor = UIColor.systemGreen
    }

    private let height: CGFloat = 84

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

        flex.define {
            $0.addItem(customTextFieldView)
            $0.addItem(validationLabel).margin(0, 25, 0, 20).height(20)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        pin.width(100%).height(height)
        flex.layout()
    }
}
