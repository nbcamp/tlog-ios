//
//  editTagViewController.swift
//  TILApp
//
//  Created by 이재희 on 10/24/23.
//

import UIKit

class TagCollectionViewController: UIViewController {
    // TODO: 태그 최대 개수 제한 생각해보기
    var tagList: [String] = []

    private lazy var prefixTF = CustomTextFieldViewWithValidation().then {
        $0.titleText = "게시물 제목에 포함될 문자"
        $0.placeholder = "ex) [TIL]"
        view.addSubview($0)
    }

    private lazy var addTagTF = CustomTextFieldView().then {
        $0.titleText = "자동 입력 태그 추가"
        $0.delegate = self
        view.addSubview($0)
    }

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let layout = TagCollectionViewFlowLayout()
        layout.minimumLineSpacing = 3
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2)

        $0.isScrollEnabled = false
        $0.delegate = self
        $0.dataSource = self
        $0.collectionViewLayout = layout
        $0.backgroundColor = .systemBackground
        $0.register(TagCollectionViewCell.self, forCellWithReuseIdentifier: "TagCollectionViewCell")

        view.addSubview($0)
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .systemBackground
        self.view = view
    }

    override func viewDidLayoutSubviews() {
        prefixTF.pin.top(view.pin.safeArea)
        addTagTF.pin.top(to: prefixTF.edge.bottom)
        collectionView.pin.top(to: addTagTF.edge.bottom).horizontally(20).bottom()
    }
}

extension TagCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as? TagCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.tagLabel.text = tagList[indexPath.item] + " x"

        return cell
    }
}

extension TagCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel().then {
            $0.font = .systemFont(ofSize: 13)
            $0.text = tagList[indexPath.item] + " x"
            $0.sizeToFit()
        }

        let size = label.frame.size

        return CGSize(width: size.width + 16, height: size.height + 10)
    }
}

extension TagCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTagIndex = indexPath.item

        if selectedTagIndex < tagList.count {
            tagList.remove(at: selectedTagIndex)

            collectionView.reloadData()
        }
    }
}

extension TagCollectionViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            tagList.append(text)
            textField.text = ""

            collectionView.reloadData()

            // 키보드 숨기기
            // textField.resignFirstResponder()
        }
        return true
    }
}
