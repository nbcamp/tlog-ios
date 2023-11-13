//
//  UserTableViewCell.swift
//  TILApp
//
//  Created by Lee on 10/29/23.
//

import UIKit

final class UserTableViewCell: UITableViewCell {
    static let identifier = #function
    let userTILView = CustomTILView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(userTILView)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        userTILView.pin.all()
    }
}
