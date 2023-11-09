import UIKit

final class LikeButton: UIButton {
    var buttonTapped: ((_ liked: Bool, _ completion: @escaping () -> Void) -> Void)?

    init(liked: Bool) {
        super.init(frame: .zero)
        isSelected = liked
        setImage(UIImage(systemName: "heart")?
            .withTintColor(.systemGray2, renderingMode: .alwaysOriginal), for: .normal)
        setImage(UIImage(systemName: "heart.fill")?
            .withTintColor(.red, renderingMode: .alwaysOriginal), for: .selected)
        tintColor = .clear
        addTarget(self, action: #selector(_buttonTapped), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func _buttonTapped() {
        buttonTapped?(isSelected, { [weak self] in
            self?.isSelected.toggle()
        })
    }
}
