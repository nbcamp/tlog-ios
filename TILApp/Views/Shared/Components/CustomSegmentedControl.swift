//
//  CustomSegmentedControl.swift
//  TILApp
//
//  Created by 이재희 on 10/27/23.
//

import FlexLayout
import PinLayout
import Then
import UIKit

// TODO: 테두리, 배경색, 폰트 등등 수정하기
class CustomSegmentedControl: UISegmentedControl {
    override init(items: [Any]?) {
        super.init(items: items)

        backgroundColor = .systemBackground
        selectedSegmentIndex = 0

        addTarget(self, action: #selector(segmentDidChange), for: .valueChanged)

        // 적용 안됨;
        for segment in subviews {
            segment.layer.cornerRadius = 0
        }
        updateBottomBorder()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func segmentDidChange() {
        updateBottomBorder()
    }

    private func updateBottomBorder() {
        layer.sublayers?.removeAll { $0.name == "bottomBorder" }

        if selectedSegmentIndex != UISegmentedControl.noSegment {
            let selectedSegment = subviews[selectedSegmentIndex]
            let bottomBorder = CALayer()
            bottomBorder.backgroundColor = UIColor.black.cgColor
            bottomBorder.frame = CGRect(
                x: selectedSegment.frame.minX,
                y: frame.size.height - 2, width: selectedSegment.frame.width, height: 2
            )
            bottomBorder.name = "bottomBorder"
            layer.addSublayer(bottomBorder)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pin.width(100%).height(30)
        updateBottomBorder()
    }
}
