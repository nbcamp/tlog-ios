//
//  SeeMoreBottomSheetViewController.swift
//  TILApp
//
//  Created by Lee on 10/24/23.
//

import FlexLayout
import PinLayout
import Then
import UIKit

class SeeMoreBottomSheetViewController: UIViewController {
    private lazy var label = UILabel().then {
        $0.text = "BottomSheet"
        $0.textAlignment = .center
        $0.backgroundColor = .systemPink
        
        view.addSubview($0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.pin.all(view.pin.safeArea)
    }
}
