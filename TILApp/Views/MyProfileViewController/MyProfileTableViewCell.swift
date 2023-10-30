//
//  MyProfileTableViewCell.swift
//  TILApp
//
//  Created by Lee on 10/30/23.
//

import UIKit

final class MyProfileTableViewCell: UITableViewCell {
    static let identifier = "MyCell"
    let myTILView = CustomTILView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUpUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        contentView.addSubview(myTILView)
        myTILView.pin.all(contentView.pin.safeArea)
    }
}
