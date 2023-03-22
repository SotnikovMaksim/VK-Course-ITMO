

import UIKit

extension UINavigationController {
    
    public func customize() {
        navigationBar.prefersLargeTitles = true
        
        navigationBar.topItem?.title = "Ваши оценки"
    }
}
