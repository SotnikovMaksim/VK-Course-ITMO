//
//  CardField.swift
//  ios-itmo-2022-assignment2
//
//  Created by mac on 08.10.2022.
//

import Foundation
import UIKit

class CardField: UIView {
    enum State {
        case capitalizedWords
        case capitalized
        case normal
    }
    
    public var characterMaxLimit: Int = 300
    
    public var characterMinLimit: Int = 1
    
    public var valid: Bool = false
    
    private lazy var field: TextField = {
        let field = TextField()
        field.translatesAutoresizingMaskIntoConstraints = false

        field.layer.cornerRadius = 8
        field.layer.borderWidth = 1
        field.setSystemColor()
        
        return field
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont(name: "Inter-Regular", size: 12)
        
        label.textColor = UIColor { tc in
                            switch tc.userInterfaceStyle {
                            case .dark:
                                return UIColor.white
                            default:
                                return UIColor.black
                            }
                        }
        return label
    }()
    
    private lazy var validationMessage: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .systemRed
        
        return label
    }()
    
    public var placeholder: String? {
        willSet {
            self.field.placeholder = newValue
        }
    }
    
    public var labelText: String? {
        willSet {
            self.label.text = newValue
        }
    }
    
    public var text: String? {
        get { self.field.text }
        set { self.field.text = newValue }
    }
    
    required init(labelText: String? = nil, placeholder: String? = nil, validation: Bool = true) {
        
        super.init(frame: .zero)
        
        if validation {
            addSubview(validationMessage)
            
            NSLayoutConstraint.activate([
                validationMessage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                validationMessage.topAnchor.constraint(equalTo: self.topAnchor),
                validationMessage.heightAnchor.constraint(equalToConstant: 15)
            ])
        }
        
        
        setupView(labelText, placeholder)
    }
    
    required init(coder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    private func setupView(_ labelText: String?, _ placeholder: String?) {
        backgroundColor = .systemBackground
        
        addSubview(field)
        addSubview(label)
        
        self.labelText = labelText
        self.placeholder = placeholder
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.heightAnchor.constraint(equalToConstant: 15),
            
            field.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            field.bottomAnchor.constraint(equalTo: bottomAnchor),
            field.leadingAnchor.constraint(equalTo: leadingAnchor),
            field.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    public func addTarget(_ target: Any?, action: Selector, for: UIControl.Event) {
        self.field.addTarget(target, action: action, for: `for`)
    }
    
    public func isValid(forState: State, acceptable: CharacterSet = .alphanumerics) {
        guard let text = self.field.text else {
            self.valid = false
            return
        }
        
        var containsAcceptable = false
        var everyWordCapitalized = false
        
        switch forState {
        case .capitalizedWords:
            containsAcceptable = (text.rangeOfCharacter(from: acceptable.union(.whitespaces).inverted) == nil)
            print("Expression: \(containsAcceptable)\n\(acceptable)")
            fallthrough
        case .capitalized:
            everyWordCapitalized = text.components(separatedBy: " ").map
            { $0 == $0.capitalized }.reduce(true) { $0 && $1 }
        default:
            break
        }
        
        if text.isEmpty {
            setNormalState()
            self.valid = false
        } else if text.count < self.characterMinLimit {
            setInvalidState(message: "миним. символов: \(self.characterMinLimit)")
            self.valid = false
        } else if forState == .capitalizedWords && (!containsAcceptable || !everyWordCapitalized) {
            setInvalidState(message: !containsAcceptable ? "только русск. и латин. буквы"
                                                         : "все слова с загл. буквы")
            self.valid = false
        } else if forState == .capitalized && !everyWordCapitalized {
            setInvalidState(message: "все слова с загл. буквы")
            self.valid = false
        } else if self.characterMaxLimit != 0 {
            if text.count > self.characterMaxLimit {
                setInvalidState(message: "макс. символов: \(self.characterMaxLimit)")
                self.valid = false
            } else {
                setNormalState()
                self.valid = true
            }
        } else {
            setNormalState()
            self.valid = true
        }
    }
    
    private func setNormalState() {
        self.validationMessage.text = ""
        self.field.setSystemBorderColor()
        self.label.textColor = UIColor { tc in
            switch tc.userInterfaceStyle {
            case .dark:
                return UIColor.white
            default:
                return UIColor.black
            }
        }
    }
    
    public func setInvalidState(message: String = "") {
        self.validationMessage.text = message
        self.field.layer.borderColor = (UIColor.systemRed).cgColor
        self.label.textColor = .systemRed
    }
}

private class TextField: UITextField {
    public var textSpacing: CGFloat = 16
    public var placeholderSpacing: CGFloat = 16
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    public var commonSpacing: CGFloat = 16 {
        willSet {
            self.textSpacing = newValue
            self.placeholderSpacing = newValue
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, placeholderSpacing, placeholderSpacing)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, textSpacing, textSpacing)
    }
    
    func setSystemBorderColor() {
        self.layer.borderColor = UIColor { tc in
            switch tc.userInterfaceStyle {
            case .dark:
                return .systemGray2
            default:
                return UIColor(red: 0.908, green: 0.908, blue: 0.908, alpha: 1)
            }
        }.cgColor
    }
    
    func setSystemBackgroundColor() {
        self.backgroundColor = UIColor { tc in
            switch tc.userInterfaceStyle {
            case .dark:
                return .systemGray4
            default:
                return UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 1)
            }
        }
    }
    
    func setSystemColor() {
        setSystemBackgroundColor()
        setSystemBorderColor()
    }
}
