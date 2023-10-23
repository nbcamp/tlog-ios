//
//  CommunityTableViewCell.swift
//  TILApp
//
//  Created by 이재희 on 10/21/23.
//

import UIKit

final class CommunityTableViewCell: UITableViewCell {
    let customCommunityTILView = CustomCommunityTILView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        contentView.addSubview(customCommunityTILView)
    }
}
