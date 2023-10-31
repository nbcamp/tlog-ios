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
        
        contentView.addSubview(customUserView)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        customUserView.pin.horizontally()
    }
}
