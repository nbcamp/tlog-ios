//
//  BlogEditViewController.swift
//  TILApp
//
//  Created by 이재희 on 10/19/23.
//

import UIKit
import Then

final class BlogEditViewController: UIViewController {
    
    var blogName: String?
    var blogURL: String?
    
    // TODO: 대표블로그인 경우 어떻게 보여줄지 로직 추가하기
    private lazy var mainBlogButton = CustomLargeBorderButton().then {
        $0.setTitle("대표 블로그로 설정하기", for: .normal)
        view.addSubview($0)
    }
    
    // TODO: 유효성 검증 로직 작성하기
    private lazy var blogNameTextField = CustomTextFieldView().then {
        $0.titleText = "블로그 이름"
        if let blogName = blogName {
            $0.mainText = blogName
        }
        $0.placeholder = "블로그 이름을 입력해주세요"
        view.addSubview($0)
    }
    
    private lazy var blogURLTextField = CustomTextFieldView().then {
        $0.titleText = "블로그 주소"
        if let blogURL = blogURL {
            $0.mainText = blogURL
        }
        $0.placeholder = "블로그 주소를 입력해주세요"
        view.addSubview($0)
    }
    
    private lazy var blogRSSTextField = CustomTextFieldView().then {
        $0.titleText = "블로그 RSS 주소"
        // TODO: RSS 주소로 수정하기
        if let blogURL = blogURL {
            $0.mainText = blogURL
        }
        $0.placeholder = "블로그 RSS 주소를 입력해주세요"
        view.addSubview($0)
    }
    
    private lazy var deleteDescriotionLabel = UILabel().then {
        $0.text = "블로그 주소를 수정하기 위해선 삭제 후 새로 등록해야 합니다."
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textAlignment = .center
        $0.textColor = .systemGray3
        view.addSubview($0)
    }
    
    private lazy var deleteBlogButton = CustomLargeBorderButton().then {
        $0.setTitle("블로그 삭제하기", for: .normal)
        $0.layer.borderColor = UIColor.systemRed.cgColor
        $0.setTitleColor(.systemRed, for: .normal)
        
        view.addSubview($0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mainBlogButton.pin.top(view.pin.safeArea).marginTop(10)
        blogNameTextField.pin.top(to: mainBlogButton.edge.bottom).marginTop(10)
        blogURLTextField.pin.top(to: blogNameTextField.edge.bottom).marginTop(-5)
        blogRSSTextField.pin.top(to: blogURLTextField.edge.bottom).marginTop(-5)
        deleteDescriotionLabel.pin.top(to: blogRSSTextField.edge.bottom).horizontally(20).height(25)
        deleteBlogButton.pin.top(to: deleteDescriotionLabel.edge.bottom)
    }
    

}
