import UIKit

final class ProfileEditViewController: UIViewController {
    private lazy var componentView = UIView().then {
        view.addSubview($0)
    }

    private lazy var editProfileImageView = UIImageView().then {
        $0.image = UIImage(systemName: "person.circle.fill")
        $0.tintColor = UIColor.accent
        $0.layer.borderColor = UIColor.accent.cgColor
        $0.layer.cornerRadius = 50
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }

    private lazy var editProfileButton = UIButton().then {
        $0.setImage(UIImage(systemName: "camera.circle"), for: .normal)
        $0.addTarget(self, action: #selector(editProfileButtonTapped), for: .touchUpInside)
        $0.backgroundColor = .white
    }

    private lazy var memberWithdrawalButton = UIButton().then {
        $0.setTitle("회원 탈퇴", for: .normal)
        $0.setTitleColor(.systemRed, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        $0.sizeToFit()
        view.addSubview($0)
        $0.addTarget(self, action: #selector(memberWithdrawalTapped), for: .touchUpInside)
    }

    private lazy var nicknameTextFieldView = CustomTextFieldViewWithValidation().then {
        $0.titleText = "유저 닉네임"
        $0.mainText = ""
        $0.placeholder = "닉네임을 입력하세요"
        $0.validationText = ""
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = .systemBackground

        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.hidesBottomBarWhenPushed = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        navigationItem.title = "프로필 수정"
        let doneBarButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(completeButtonTapped))
        navigationItem.rightBarButtonItem = doneBarButton
        editProfileImageView.isUserInteractionEnabled = true
        editProfileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped(_:))))
        AuthViewModel.shared.profile(
            onSuccess: { [weak self] user in
                guard let self else {return}
                nicknameTextFieldView.mainText = user.username
                
            }, onError: { error in
                let alert = UIAlertController(title: "오류", message: "다시 시도 해주세요.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default) { action in
                    self.navigationController?.popViewController(animated: true)
                })
                
                self.present(alert, animated: true, completion: nil)
            })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpUI()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    private func setUpUI() {
        componentView.flex.direction(.column).marginTop(40).define { flex in
            flex.addItem().direction(.row).justifyContent(.center).define { flex in
                flex.addItem(editProfileImageView).width(100).height(100)
                flex.addItem(editProfileButton).position(.absolute).size(24).cornerRadius(12)
                    .bottom(8%).right(38%)
            }
            flex.addItem(nicknameTextFieldView).marginTop(10)
        }
        componentView.pin.top(view.pin.safeArea).bottom(50%).left(view.pin.safeArea).right(view.pin.safeArea)
        componentView.flex.layout()
        memberWithdrawalButton.pin.bottom(view.pin.safeArea).hCenter()
    }

    @objc private func editProfileButtonTapped() {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.allowsEditing = true
//        present(imagePicker, animated: true, completion: nil)
    }

    @objc private func profileImageViewTapped(_ sender: UITapGestureRecognizer) {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.allowsEditing = true
//        present(imagePicker, animated: true, completion: nil)
    }

    @objc private func completeButtonTapped() {
        let newNickname = nicknameTextFieldView.mainText
        let updateInput = UpdateUserInput(username: newNickname, avatarUrl: nil)
        AuthViewModel.shared.update(updateInput, onSuccess: { [weak self] _ in
            guard let self else { return }
            navigationController?.popViewController(animated: true)
        }, onError: { [weak self] _ in
            guard let self else { return }
            let alert = UIAlertController(title: "업데이트 실패", message: "다시 시도 해주세요.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        })
    }

    @objc private func memberWithdrawalTapped() {
        let alertController = UIAlertController(title: "회원 탈퇴", message: "정말로 회원 탈퇴를 하시겠습니까?", preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "확인", style: .destructive) { [weak self] _ in
            AuthViewModel.shared.withdraw()
            let alert = UIAlertController(title: "회원 탈퇴 성공", message: "\n다음에 또 이용해 주십시오.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        }
        alertController.addAction(confirmAction)

        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    private func validateNickname() {
        // TODO: 닉네임 유효성 검사 로직
//        let nickname = nicknameTextFieldView.text
//        if {
//            print("통과")
//            nicknameTextFieldView.validationText = "유효한 닉네임입니다."
//        } else {
//            print("불통")
//            nicknameTextFieldView.validationText = "사용 불가능한 닉네임입니다.."
//        }
    }
}

// TODO: 이미구현후 주석 풀기
// extension ProfileEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//        if let editedImage = info[.editedImage] as? UIImage {
//            editProfileImageView.image = editedImage
//            print("선택한 이미지: \(editedImage)")
//        }
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
// }
