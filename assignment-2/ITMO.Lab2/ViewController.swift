//
//  ViewController.swift
//  ios-itmo-2022-assignment2
//
//  Created by rv.aleksandrov on 29.09.2022.
//

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
    
    private lazy var yearCard: CardField = {
        let card = CardField()
        card.labelText = "Год"
        card.placeholder = "Год выпуска"
        return card
    }()
    
    private lazy var rateBar: RateBar = {
        let leftBorder: CGFloat = 49.5, rightBorder: CGFloat = 49.5
        let textHeight: CGFloat = 19, textWidth: CGFloat = 103
        let starsSize: CGFloat = 42.5
        let padding: CGFloat = 20
        let bar: RateBar
        
        bar = RateBar(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.frame.width - leftBorder - rightBorder,
                height: starsSize + padding + textHeight
            ),
            additionalText: "Ваша оценка",
            textWidth: textWidth,
            textHeight: textHeight,
            padding: padding,
            subscription: (target: self, action: #selector(textFieldDidChange))
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        [
            pageLabel,
            filmNameCard,
            directorNameCard,
            yearCard,
            rateBar,
            confirmButton,
            autofillingButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        [
            filmNameCard,
            directorNameCard,
            yearCard
        ].forEach {
            $0.addTarget(self, action: #selector(textFieldDidChange), for: UIControl.Event.editingChanged)
        }
        
        configureContraints()
    }
    
    private func configureContraints() {
        NSLayoutConstraint.activate([
            pageLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            pageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageLabel.heightAnchor.constraint(equalToConstant: 40),
            pageLabel.widthAnchor.constraint(equalToConstant: 120),
            
            filmNameCard.heightAnchor.constraint(equalToConstant: 73),
            filmNameCard.topAnchor.constraint(equalTo: view.topAnchor, constant: 136),
            filmNameCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filmNameCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            directorNameCard.heightAnchor.constraint(equalToConstant: 73),
            directorNameCard.topAnchor.constraint(equalTo: filmNameCard.bottomAnchor, constant: 16),
            directorNameCard.leadingAnchor.constraint(equalTo: filmNameCard.leadingAnchor),
            directorNameCard.trailingAnchor.constraint(equalTo: filmNameCard.trailingAnchor),
            
            yearCard.heightAnchor.constraint(equalToConstant: 73),
            yearCard.topAnchor.constraint(equalTo: directorNameCard.bottomAnchor, constant: 16),
            yearCard.leadingAnchor.constraint(equalTo: filmNameCard.leadingAnchor),
            yearCard.trailingAnchor.constraint(equalTo: filmNameCard.trailingAnchor),
            
            rateBar.topAnchor.constraint(equalTo: yearCard.bottomAnchor, constant: 48),
            rateBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            rateBar.widthAnchor.constraint(equalToConstant: rateBar.frame.width),
            rateBar.heightAnchor.constraint(equalToConstant: rateBar.frame.height),
            
            confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            confirmButton.heightAnchor.constraint(equalToConstant: 51),
            confirmButton.widthAnchor.constraint(equalToConstant: 343),
            confirmButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -46),

            
            autofillingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            autofillingButton.heightAnchor.constraint(equalToConstant: 51),
            autofillingButton.widthAnchor.constraint(equalToConstant: 343),
            autofillingButton.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -20)
        ])
    }
    
    @objc
    func textFieldDidChange() {
        directorNameCard.isValid(forState: .capitalizedWords, acceptable: .letters)
        filmNameCard.isValid(forState: .normal)
        yearCard.isValid(forState: .normal, acceptable: .decimalDigits)

        if directorNameCard.valid
            && filmNameCard.valid
            && yearCard.valid
            && rateBar.rated
        {
            confirmButton.isEnabled = true
            confirmButton.alpha = 1
        } else {
            confirmButton.isEnabled = false
            confirmButton.alpha = 0.4
        }
    }
    
    private func createButton(text: String, color: CGColor) -> UIButton {
        let button = UIButton()
        
        button.layer.backgroundColor = color
        
        button.setTitle(text, for: .normal)
        
        button.setTitleColor(.white, for: .normal)

        button.layer.cornerRadius = 24
        
        return button
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
        
        textFieldDidChange()
    }
    
    private func randomFromSequence(_ sequence: String, _ length: Int) -> String {
        return String((0..<length).compactMap{ _ in sequence.randomElement() })
    }
}
