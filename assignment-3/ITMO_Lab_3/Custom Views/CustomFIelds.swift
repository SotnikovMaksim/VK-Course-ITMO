

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
    
    fileprivate lazy var field: TextField = {
        let field = TextField()
        field.translatesAutoresizingMaskIntoConstraints = false

        field.layer.cornerRadius = 8
        field.layer.borderWidth = 1
        field.setSystemColor()
        
        return field
    }()
    
    fileprivate lazy var label: UILabel = {
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
    
    init(labelText: String? = nil, placeholder: String? = nil, validation: Bool = true) {
        
        super.init(frame: .zero)
        
        configureValidateion(validation)
        
        setupView(labelText, placeholder)
    }
    
    private func configureValidateion(_ validation: Bool) {
        if validation {
            addSubview(validationMessage)
            
            NSLayoutConstraint.activate([
                validationMessage.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                validationMessage.topAnchor.constraint(equalTo: self.topAnchor),
                validationMessage.heightAnchor.constraint(equalToConstant: 15)
            ])
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    fileprivate func setupView(_ labelText: String?, _ placeholder: String?) {
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
    
//    public func isValid(forState: State, acceptable: CharacterSet = .alphanumerics) {
//        guard let text = self.field.text else {
//            self.valid = false
//            return
//        }
//
//        var containsAcceptable = false
//        var everyWordCapitalized = false
//
//        switch forState {
//        case .capitalizedWords:
//            containsAcceptable = (text.rangeOfCharacter(from: acceptable.union(.whitespaces).inverted) == nil)
//            fallthrough
//        case .capitalized:
//            everyWordCapitalized = text.components(separatedBy: " ").map
//            { $0 == $0.capitalized }.reduce(true) { $0 && $1 }
//        default:
//            break
//        }
//
//        if text.isEmpty {
//            setNormalState()
//            self.valid = false
//        } else if text.count < self.characterMinLimit {
//            setInvalidState(message: "миним. символов: \(self.characterMinLimit)")
//            self.valid = false
//        } else if forState == .capitalizedWords && (!containsAcceptable || !everyWordCapitalized) {
//            setInvalidState(message: !containsAcceptable ? "только русск. и латин. буквы"
//                                                         : "все слова с загл. буквы")
//            self.valid = false
//        } else if forState == .capitalized && !everyWordCapitalized {
//            setInvalidState(message: "все слова с загл. буквы")
//            self.valid = false
//        } else if self.characterMaxLimit != 0 {
//            if text.count > self.characterMaxLimit {
//                setInvalidState(message: "макс. символов: \(self.characterMaxLimit)")
//                self.valid = false
//            } else {
//                setNormalState()
//                self.valid = true
//            }
//        } else {
//            setNormalState()
//            self.valid = true
//        }
//    }
    
    public func setNormalState() {
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

//MARK: - Hide keyboard by tap on Return

extension CardField: UITextFieldDelegate {
//    TODO: it doesn't work yet :(
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

class DateField: CardField {
    
    fileprivate lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        
        datePicker.datePickerMode = .date
        datePicker.timeZone = TimeZone.current
        datePicker.preferredDatePickerStyle = .wheels
        
        return datePicker
    }()
    
    required init(labelText: String?, placeholder: String?, subscription: (target: Any, action: Selector)? = nil) {

        super.init(labelText: labelText, placeholder: placeholder)
        
        super.field.inputView = self.datePicker
        
        if let (target, action) = subscription {
            self.datePicker.addTarget(target, action: action, for: .valueChanged)
        }
        
        setupView()
        
        addAccessoryView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {

          
    }

}

//MARK: - ACCESSORY VIEW SETUP

extension DateField {
    
    private func addAccessoryView() {
        let toolbar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0,
                                              width: UIScreen.main.bounds.width,
                                              height: 44.0))

        toolbar.center = CGPointMake(UIScreen.main.bounds.width / 2, 200)
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(
            title: "Готово",
            style: .done,
            target: self,
            action: #selector(tapDone)
        )
        
        let cancelButton = UIBarButtonItem(
            title: "Отмена",
            style: .plain,
            target: self,
            action: #selector(tapCancel)
        )
        
        toolbar.setItems([cancelButton, flexibleSpace, doneButton], animated: true)
        toolbar.sizeToFit()
        
        self.field.inputAccessoryView = toolbar
    }
    
    @objc
    private func tapCancel() {
        self.field.resignFirstResponder()
    }
    
    @objc
    private func tapDone() {
        self.field.resignFirstResponder()
        
        guard let datePicker = self.field.inputView as? UIDatePicker else {
            return
        }
        
        let dateformatter = DateFormatter()
            
        dateformatter.dateFormat = "dd.MM.YYYY"
            
        self.field.text = dateformatter.string(from: datePicker.date)
    }
}
