

import Foundation

extension String {

    enum ValidType {
        case name
        case latinCyrillic
        case length(of: UInt)
    }
    
    enum Regex: String {
        case name = "(([A-ZА-Я][a-zа-я]* )|([A-ZА-Я][a-zа-я]+))*"
        case latinCyrillic = "[A-ZА-Яa-zа-я ]*"
    }
    
    func isValid(validType: ValidType) -> Bool {
        let format = "SELF MATCHES %@"
        var regex = ""
        
        switch validType {
        case .name:
            regex = Regex.name.rawValue
        case .latinCyrillic:
            regex = Regex.latinCyrillic.rawValue
        case .length(of: let n):
            return self.count >= n
        }
        
        return NSPredicate(format: format, regex).evaluate(with: self)
    }
    
}
