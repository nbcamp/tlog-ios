import UIKit

class CustomSegmentedControl: UISegmentedControl {
    private lazy var halfLineView = UIView().then {
        $0.backgroundColor = .black
        $0.pin.height(2)
    }
    
    private lazy var lineView = UIView().then {
        $0.backgroundColor = .systemGray5
        $0.pin.height(2)
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        
        self.removeBackgroundAndDivider()
        
        selectedSegmentIndex = 0
        
        setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.systemGray,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .light)
        ], for: .normal)
        
        setTitleTextAttributes([
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)
        ], for: .selected)
        
        pin.height(40)
        
        addSubview(lineView)
        addSubview(halfLineView)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 0.0
        
        pin.width(100%)
        self.lineView.pin.bottom(to: self.edge.bottom).width(100%)
        
        let halfLineXPos = self.bounds.width / 2 * CGFloat(self.selectedSegmentIndex)
        UIView.animate(
            withDuration: 0.1,
            animations: {
                self.halfLineView.frame.origin.x = halfLineXPos
            }
        )
        self.halfLineView.pin.bottom(to: self.edge.bottom).width(50%)
    }
    
    private func removeBackgroundAndDivider() {
        let image = UIImage()
        
        self.setBackgroundImage(image, for: .normal, barMetrics: .default)
        self.setBackgroundImage(image, for: .selected, barMetrics: .default)
        self.setBackgroundImage(image, for: .highlighted, barMetrics: .default)
        
        self.setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
    }
}
