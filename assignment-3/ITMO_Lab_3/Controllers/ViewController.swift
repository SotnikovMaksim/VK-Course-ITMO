import UIKit

class ViewController: UIViewController {
    private lazy var pageLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Фильм"
        label.font = label.font.withSize(30)
        label.textColor =  UIColor { tc in
            switch tc.userInterfaceStyle {
            case .dark:
                return UIColor.white
            default:
                return UIColor.black
            }
        }
        
        return label
    }()
    
    private lazy var filmNameCard: CardField = {
        let card = CardField()
        card.labelText = "Название"
        card.placeholder = "Название фильма"
        return card
    }()
    
    private lazy var directorNameCard: CardField = {
        let card = CardField()
        card.labelText = "Режиссёр"
        card.placeholder = "Режиссёр фильма"
        card.characterMinLimit = 3
        return card
    }()
    
    private lazy var yearCard: DateField = {
        let labelText: String = "Год"
        let placeholder: String = "Год выпуска"
        let datePicker = DateField(
            labelText: labelText,
            placeholder: placeholder,
            subscription: (self, #selector(validateFields))
        )
        
        return datePicker
    }()
    
    private lazy var rateBar: RatingBar = {
        let leftBorder: CGFloat = 49.5, rightBorder: CGFloat = 49.5
        let textHeight: CGFloat = 19, textWidth: CGFloat = 103
        let starsSize: CGFloat = 42.5
        let padding: CGFloat = 20
        let bar: RatingBar
        
        bar = RatingBar(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.frame.width - leftBorder - rightBorder,
                height: starsSize + padding + textHeight
            ),
            additionalText: "Ваша оценка",
            textWidth: textWidth,
            textHeight: textHeight,
            padding: padding
        )
        
        bar.starCount = 5
        
        return bar
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = createButton(
            text: "Сохранить",
            color: UIColor(red: 0.366, green: 0.692, blue: 0.457, alpha: 1).cgColor
        )
        
        button.isEnabled = false
        button.alpha = 0.4
        button.layer.shadowOpacity = 0.7
        button.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        button.layer.shadowRadius = 15.0
        button.layer.shadowColor = UIColor.systemGray3.cgColor
        button.addTarget(self, action: #selector(saveFilm), for: .touchUpInside)
        button.addTarget(self, action: #selector(popViewController), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var autofillingButton: UIButton = {
        let button = createButton(
            text: "Заполнить",
            color: UIColor.systemBlue.cgColor
        )

        button.addTarget(self, action: #selector(autofill), for: .touchUpInside)

        return button
    }()
    
    private lazy var cardsStack: UIStackView = {
        let cardsStack = UIStackView(items: [filmNameCard,
                                             directorNameCard,
                                             yearCard],
                                      axis: .vertical,
                                      spacing: 16,
                                      distribution: .fillEqually)
        
        return cardsStack
    }()
    
    weak var delegate: ViewControllerDelegate?
    
    private var token: NSKeyValueObservation?
    
    override func viewWillAppear(_ animated: Bool) {
        let backBarButton = UIBarButtonItem(title: "Отмена", style: .done, target: self, action: #selector(popViewController))
        
        self.navigationItem.leftBarButtonItem = backBarButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        self.setupTapGestureRecognizer()
        
    }
}

//MARK: - Controller setup

extension ViewController {
    private func setupView() {
        view.backgroundColor = .systemBackground
        token = rateBar.observe(\.rating) { _,_  in self.validateFields() }
        
        [
            pageLabel,
            cardsStack,
            rateBar,
            confirmButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        [
            filmNameCard,
            directorNameCard,
            yearCard
        ].forEach {
            $0.addTarget(self, action: #selector(validateFields), for: UIControl.Event.editingChanged)
        }
        
        self.setupTapGestureRecognizer()
        
        self.setupContraints()
    }

    private func setupContraints() {
        NSLayoutConstraint.activate([
            pageLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            pageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageLabel.heightAnchor.constraint(equalToConstant: 40),
            pageLabel.widthAnchor.constraint(equalToConstant: 120),
            
            cardsStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 136),
            cardsStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -425),
            cardsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            rateBar.topAnchor.constraint(equalTo: cardsStack.bottomAnchor, constant: 48),
            rateBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rateBar.widthAnchor.constraint(equalToConstant: rateBar.frame.width),
            rateBar.heightAnchor.constraint(equalToConstant: rateBar.frame.height),
            
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            confirmButton.widthAnchor.constraint(equalToConstant: 340),
            confirmButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
}
    
//MARK: - Modification 14.10

extension ViewController {

    private func setupModification() {
        NSLayoutConstraint.activate([
            autofillingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            autofillingButton.heightAnchor.constraint(equalToConstant: 51),
            autofillingButton.widthAnchor.constraint(equalToConstant: 343),
            autofillingButton.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -20)
        ])
    }
    
    @objc
    private func autofill() {
        let digits = "1234567890"
        let alpha = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ "
        let alphaDigits = digits + alpha
        let date = "\(randomFromSequence(digits, 2)).\(randomFromSequence(digits, 2)).\(randomFromSequence(digits, 4))"
        let filmName = randomFromSequence(alphaDigits, Int.random(in: 1...300))
        let directorName = randomFromSequence(alpha, Int.random(in: 3...300))
        
        self.yearCard.text = date
        self.directorNameCard.text = directorName
        self.filmNameCard.text = filmName
        self.validateFields()
    }

    private func randomFromSequence(_ sequence: String, _ length: Int) -> String {
        return String((0..<length).compactMap{ _ in sequence.randomElement() })
    }
}

//MARK: - Hide keyboard by tap under it

extension ViewController {
    
    func setupTapGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//MARK: - Auxiliary methods

extension ViewController {
    
    private func createButton(text: String, color: CGColor) -> UIButton {
        let button = UIButton()
        
        button.layer.backgroundColor = color
        button.setTitle(text, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 24
        
        return button
    }
}

//MARK: - Fields validation

extension ViewController {
    @objc
    func validateFields() {
        let directorNameValid = checkField(field: self.directorNameCard,
                                           validationArguments: [(.length(of: 3), "миним. символов, 3"),
                                                                 (.latinCyrillic, "только русск. и латин. буквы"),
                                                                 (.name, "имена с загл. буквы")])
        
        let filmNameValid = checkField(field: self.filmNameCard,
                                       validationArguments: [(.length(of: 3), "миним. символов: 1")])
        
        if directorNameValid
        && filmNameValid
        && rateBar.rated
        {
            confirmButton.isEnabled = true
            confirmButton.alpha = 1
        } else {
            confirmButton.isEnabled = false
            confirmButton.alpha = 0.4
        }
    }
    
    func checkField(field: CardField, validationArguments: [(validType: String.ValidType, message: String)]) -> Bool {
        guard let text = field.text else {
            return true
        }
        
        if text.count == 0 {
            field.setNormalState()
            return true
        }
        
        for (validType, message) in validationArguments {
            if !text.isValid(validType: validType) {
                field.setInvalidState(message: message)
                return false
            } else {
                field.setNormalState()
            }
        }
        
        return true
    }
}

//MARK: - Pop bback current view controller. Sending film data

extension ViewController {
    @objc
    func saveFilm() {
        guard let delegate = self.delegate else {
            return
        }
        
        let (film, director, date, rating) = (self.filmNameCard.text ?? "",
                                              self.directorNameCard.text ?? "",
                                              self.yearCard.text ?? "",
                                              self.rateBar.rating)
        
        delegate.addFilm(film: film, director: director, date: date, rating: rating)
    }

    @objc
    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}
