

import Foundation

extension Array<String> {

    func findUpperBoundIndex(of element: String) -> Int? {

        for (i, arrayElement) in self.enumerated() {
            if arrayElement >= element {
                return i
            }
        }
        
        return nil
    }
}
