

import UIKit

extension UINavigationController {
    
    public func changeBackButtonText(text: String) {
        let backBarButton = UIBarButtonItem(title: text, style: .plain, target: nil, action: nil)
        
        navigationItem.backBarButtonItem = backBarButton
    }
    
}
