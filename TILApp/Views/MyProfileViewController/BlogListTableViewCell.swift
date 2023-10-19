//
//  BlogListTableViewCell.swift
//  TILApp
//
//  Created by 이재희 on 10/19/23.
//

import UIKit
import PinLayout

class BlogListTableViewCell: UITableViewCell {
    
    let customBlogView = CustomBlogView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(customBlogView)
    }
    
}
