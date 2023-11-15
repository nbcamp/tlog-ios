import UIKit

class AgreeTermsViewController: UIViewController {
    private let logoImage = UIImageView(image: UIImage(named: "SignInPageLogo"))

    private let agreeButton = UIButton().then {
        $0.backgroundColor = .white
        $0.alpha = 0.6
        $0.setTitle("동의하고 계속하기", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 18)
        $0.layer.cornerRadius = 24
        $0.pin.height(48)
    }

    private let checkbox = UIButton().then {
        $0.setImage(UIImage(named: "checkbox.unchecked"), for: .normal)
        $0.setImage(UIImage(named: "checkbox.checked"), for: .selected)
        $0.pin.width(16).height(16)
    }

    private lazy var termsLabel = createCustomLabel(text: "이용 약관", isUnderlined: true)
    private lazy var andLabel = createCustomLabel(text: " 및 ")
    private lazy var privacyPolicyLabel = createCustomLabel(text: "개인정보 처리방침", isUnderlined: true)
    private lazy var agreementLabel = createCustomLabel(text: "에 동의합니다.")
    private let checkboxContainerView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        logoImage.contentMode = .scaleAspectFill
        view.addSubview(logoImage)

        agreeButton.isEnabled = false
        view.addSubview(agreeButton)

        view.addSubview(checkboxContainerView)
        checkboxContainerView.flex.direction(.row).alignItems(.center).justifyContent(.center).define { flex in
            flex.addItem(checkbox).width(16).height(16)
            flex.addItem(termsLabel).marginLeft(5)
            flex.addItem(andLabel)
            flex.addItem(privacyPolicyLabel)
            flex.addItem(agreementLabel)
        }
        checkboxContainerView.pin.height(20)

        let tapGestureTerms = UITapGestureRecognizer(target: self, action: #selector(openTerms))
        termsLabel.addGestureRecognizer(tapGestureTerms)

        let tapGesturePrivacy = UITapGestureRecognizer(target: self, action: #selector(openPrivacyPolicy))
        privacyPolicyLabel.addGestureRecognizer(tapGesturePrivacy)

        checkbox.addTarget(self, action: #selector(checkboxTapped), for: .touchUpInside)

        agreeButton
            .addTarget(self, action: #selector(agreeButtonTapped), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        view.pin.all()
        logoImage.pin.all()
        agreeButton.pin.hCenter().bottom(17%).width(85%).height(48)
        checkboxContainerView.pin.horizontally().bottom(to: agreeButton.edge.top).marginBottom(10)

        checkboxContainerView.flex.layout()
    }

    @objc private func agreeButtonTapped() {
        // TODO: authUser 동의 여부 갱신
        dismiss(animated: false)
    }

    @objc func checkboxTapped() {
        checkbox.isSelected.toggle()
        agreeButton.isEnabled = checkbox.isSelected
        agreeButton.alpha = agreeButton.isEnabled ? 1.0 : 0.6
    }

    @objc private func openTerms() {
        let webViewController = WebViewController()
        webViewController.url = "https://plucky-fang-eae.notion.site/e951a2d004ac4bbdbee73ee6b8ea4d08"
        webViewController.hidesBottomBarWhenPushed = true
        present(webViewController, animated: true)
    }

    @objc private func openPrivacyPolicy() {
        let webViewController = WebViewController()
        webViewController.url = "https:plip.kr/pcc/96e3cd8c-700d-46a1-b007-37443c721874/privacy-policy"
        webViewController.hidesBottomBarWhenPushed = true
        present(webViewController, animated: true)
    }

    private func createCustomLabel(text: String, isUnderlined: Bool = false) -> UILabel {
        return UILabel().then {
            if isUnderlined {
                var attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 14),
                    .foregroundColor: UIColor.white,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ]
                let attributedString = NSAttributedString(string: text, attributes: attributes)
                $0.attributedText = attributedString
            } else {
                $0.text = text
                $0.font = UIFont.systemFont(ofSize: 14)
                $0.textColor = .white
            }

            $0.isUserInteractionEnabled = isUnderlined
            $0.sizeToFit()
        }
    }
}
