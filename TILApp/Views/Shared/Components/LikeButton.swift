import UIKit

final class LikeButton: UIButton {
    var buttonTapped: ((_ liked: Bool, _ completion: @escaping (Bool) -> Void) -> Void)?

    init(liked: Bool) {
        super.init(frame: .zero)
        isSelected = liked
        setImage(UIImage(systemName: "heart")?
            .withTintColor(.systemGray2, renderingMode: .alwaysOriginal), for: .normal)
        setImage(UIImage(systemName: "heart")?
            .withTintColor(.red, renderingMode: .alwaysOriginal), for: .selected)
        tintColor = .clear

        configuration = .plain()
        configurationUpdateHandler = {
            switch $0.state {
            case .disabled: $0.imageView?.tintAdjustmentMode = .dimmed
            default: $0.imageView?.tintAdjustmentMode = .normal
            }
        }

        addTarget(self, action: #selector(_buttonTapped), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func _buttonTapped() {
        guard let buttonTapped else { return }
        let liked = isSelected
        isSelected.toggle()
        buttonTapped(liked) { [weak self] state in
            self?.isSelected = state
        }
    }
}
