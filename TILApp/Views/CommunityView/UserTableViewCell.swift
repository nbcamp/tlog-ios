//
//  UserTableViewCell.swift
//  TILApp
//
//  Created by Lee on 10/29/23.
//

import UIKit

final class UserTableViewCell: UITableViewCell {
    static let identifier = "UserCell"
    let userTILView = CustomTILView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setUpUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        contentView.addSubview(userTILView)
    }
}
