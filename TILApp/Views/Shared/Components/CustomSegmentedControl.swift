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

    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        pin.width(100%).height(40)
    }
}
