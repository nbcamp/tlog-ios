//
//  FollowListTableViewCell.swift
//  TILApp
//
//  Created by 이재희 on 10/23/23.
//

import UIKit

final class FollowListTableViewCell: UITableViewCell {
    let customUserView = CustomUserView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(customUserView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        customUserView.pin.horizontally()
    }
}
