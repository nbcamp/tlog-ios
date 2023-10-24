//
//  SeeMorePresentationController.swift
//  TILApp
//
//  Created by Lee on 10/24/23.
import FlexLayout
import PinLayout
import Then
import UIKit

class SeeMorePresentationController: UIPresentationController {
    private lazy var flexView = UIView().then {
        $0.backgroundColor = .white
    }

    private lazy var dimmingView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        $0.alpha = 0.0
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        $0.addGestureRecognizer(recognizer)
    }

    override func presentationTransitionWillBegin() {
        print("1단계 presentationTransitionWillBegin()")

        setUpUI()
    }

    private func setUpUI() {
        flexView.flex.direction(.column).define { flex in
            flex.addItem().flex.grow(1)
            flex.addItem().flex.grow(1)
            flex.addItem().flex.grow(1)
        }
        flexView.flex.layout()
        flexView.pin.all(view.pin.safeArea)
    }
}

extension SeeMorePresentationController {
    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true)
    }
}
