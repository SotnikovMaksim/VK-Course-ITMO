

import UIKit

extension UIStackView {
    
    convenience init(items: [UIView], axis: NSLayoutConstraint.Axis, spacing: CGFloat,
                     distribution: UIStackView.Distribution) {
        
        self.init(arrangedSubviews: items)
        
        self.axis = axis
        
        self.spacing = spacing
        
        self.distribution = distribution
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
