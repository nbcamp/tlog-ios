//
//  CustomBlogView.swift
//  TILApp
//
//  Created by 이재희 on 10/27/23.
//

import FlexLayout
import PinLayout
import Then
import UIKit

class CustomBlogView: UIView {
    enum Variant {
        case primary
        case normal
    }

    var variant: Variant = .normal {
        didSet {
            switch variant {
            case .primary:
                addSubview(primaryLabel)
            case .normal:
                primaryLabel.removeFromSuperview()
            }
        }
    }

    var blogNameText: String {
        get { customLabelView.nicknameText }
        set { customLabelView.nicknameText = newValue }
    }

    var blogURLText: String {
        get { customLabelView.dateText }
        set { customLabelView.dateText = newValue }
    }

    private let customLabelView = CustomLabelView()
    private let chevronImage = UIImageView(image: UIImage(
        systemName: "chevron.right",
        withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
    ))
    private let primaryLabel = UILabel().then {
        $0.text = "대표 블로그"
        $0.font = UIFont.systemFont(ofSize: 13)
        $0.textColor = UIColor(named: "AccentColor")
        $0.sizeToFit()
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

        chevronImage.tintColor = UIColor(named: "AccentColor")
        chevronImage.contentMode = .scaleAspectFit

        addSubview(customLabelView)
        addSubview(chevronImage)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        pin.width(100%).height(67)

        chevronImage.pin.width(20).height(20).centerRight(20)
        customLabelView.pin.left(20).before(of: chevronImage).marginRight(70)

        switch variant {
        case .primary:
            primaryLabel.pin.right(to: chevronImage.edge.left).vCenter()
        case .normal:
            break
        }
    }
}
