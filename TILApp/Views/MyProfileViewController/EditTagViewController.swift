//
//  editTagViewController.swift
//  TILApp
//
//  Created by 이재희 on 10/24/23.
//

import UIKit

final class EditTagViewController: UIViewController {
    // TODO: 태그 최대 개수 제한 생각해보기
    enum Variant {
        case add
        case update
    }

    var variant: Variant = .add {
        didSet {
            switch variant {
            case .add:
                title = "키워드 등록"
            case .update:
                title = "키워드 수정"
                keyword = keywordInputViewModel.keywords[selectedIndex]
            }
        }
    }

    var selectedIndex: Int = -1
    var keyword: KeywordInput = .init(keyword: "", tags: [])

    private let blogViewModel = BlogViewModel.shared
    private let keywordInputViewModel = KeywordInputViewModel.shared

    private lazy var prefixTF = CustomTextFieldViewWithValidation().then {
        $0.titleText = "게시물 제목에 포함될 문자"
        $0.placeholder = "ex) [TIL]"
        $0.mainText = keyword.keyword
        $0.textFieldTag = 0
        if variant == .update {
            $0.isValid = true
        }
        $0.delegate = self
        view.addSubview($0)
    }

    private lazy var addTagTF = CustomTextFieldView().then {
        $0.titleText = "자동 입력 태그 추가"
        $0.placeholder = "태그를 입력하고 키보드 리턴 키를 눌러주세요"
        $0.textFieldTag = 1
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

        view.backgroundColor = .systemBackground

        let doneButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(doneButtonTapped))
        navigationItem.rightBarButtonItem = doneButton

        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        prefixTF.pin.horizontally().top(view.pin.safeArea).marginTop(10)
        addTagTF.pin.top(to: prefixTF.edge.bottom)
        collectionView.pin.top(to: addTagTF.edge.bottom).horizontally(20).bottom()
    }

    @objc private func doneButtonTapped() {
        keyword.keyword = prefixTF.mainText
        switch variant {
        case .add:
            keywordInputViewModel.add(keyword: keyword)
        case .update:
            keywordInputViewModel.update(index: selectedIndex, keyword: keyword)
        }

        navigationController?.popViewController(animated: true)
    }

    private func updateDoneButtonState() {
        navigationItem.rightBarButtonItem?.isEnabled = keyword.tags.count > 0 && prefixTF.isValid
    }
}

extension EditTagViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return keyword.tags.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as? TagCollectionViewCell else {
            return UICollectionViewCell()
        }

        let xString = NSAttributedString(string: " x", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])

        let combinedString = NSMutableAttributedString(string: keyword.tags[indexPath.item])
        combinedString.append(xString)

        cell.tagLabel.attributedText = combinedString

        return cell
    }
}

extension EditTagViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel().then {
            $0.font = .systemFont(ofSize: 13)
            $0.text = (keyword.tags[indexPath.item]) + " x"
            $0.sizeToFit()
        }

        let size = label.frame.size

        return CGSize(width: size.width + 16, height: size.height + 10)
    }
}

extension EditTagViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTagIndex = indexPath.item

        if selectedTagIndex < keyword.tags.count {
            keyword.tags.remove(at: selectedTagIndex)
            updateDoneButtonState()
            collectionView.reloadData()
        }
    }
}

extension EditTagViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            if textField.tag == 0 {
                textField.resignFirstResponder()
            } else if textField.tag == 1 {
                if !keyword.tags.contains(text) {
                    keyword.tags.append(text)
                    updateDoneButtonState()
                    collectionView.reloadData()
                }
                textField.text = ""
            }
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 0 {
            if let currentText = textField.text,
               let range = Range(range, in: currentText)
            {
                let updatedText = currentText.replacingCharacters(in: range, with: string)

                if updatedText.isEmpty {
                    prefixTF.isValid = false
                    prefixTF.validationText = ""
                } else if variant == .update && updatedText == keyword.keyword {
                    prefixTF.isValid = true
                    prefixTF.validationText = ""
                } else {
                    let isDuplicate = keywordInputViewModel.has(keywordToCheck: updatedText)
                    prefixTF.isValid = !isDuplicate
                    prefixTF.validationText = isDuplicate ? "중복된 키워드입니다." : "유효한 키워드입니다."
                }

                updateDoneButtonState()
            }
        }

        return true
    }
}
