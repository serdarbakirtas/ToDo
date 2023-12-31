import Foundation
import UIKit

class RightBarButtonItem: UIBarButtonItem {

    var tapAction: (() -> Void)?

    private let button = UIButton()

    override init() {
        super.init()
        setup()
        updateTitleColor(false)
    }

    init(with name: String?) {
        super.init()
        setup(name: name)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}

// MARK: Actions

private extension RightBarButtonItem {
    
    @objc private func buttonPressed() {
        if let action = tapAction {
            action()
        }
    }
}

// MARK: Public functions

extension RightBarButtonItem {
    
    func updateTitleColor(_ isEnabled: Bool) {
        button.setTitleColor(isEnabled ? .black : .lightGray, for: .normal)
    }
}

// MARK: Private functions

private extension RightBarButtonItem {
    
    private func setup(name: String? = nil) {
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.setTitle(name, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        customView = button
    }
}
