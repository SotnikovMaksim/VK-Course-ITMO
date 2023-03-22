

import Foundation
import UIKit

class RatingBar: UIView {
    
    public var rated: Bool { self.rating != .none }
    
    private var additionalText: UILabel? = nil
    
    private lazy var stars: [UIButton] = []
    
    public var additionalTextPadding: CGFloat = 20
    public var starPadding: CGFloat
    public var starSize: CGFloat
    
    public var starCount: Int = 5
    
    private var ratingChangeEvent: UIControl.Event

    @objc dynamic public var rating: Rating = .none
    
    required init(frame: CGRect, ratingChangeEvent: UIControl.Event = .touchDown) {
        
        self.starSize = frame.height
        
        self.ratingChangeEvent = ratingChangeEvent
        
        self.starPadding = (frame.width - CGFloat(starCount) * self.starSize)
                         / CGFloat(starCount - 1)
        
        super.init(frame: frame)
        
        setupView()
    }
    
/// Contructor for RateBar with label
    init(frame: CGRect, additionalText: String, textWidth: CGFloat, textHeight: CGFloat,
         padding: CGFloat, ratingChangeEvent: UIControl.Event = .touchDown) {
        
        self.starSize = frame.height - self.additionalTextPadding - textHeight
        
        self.starPadding = (frame.width - CGFloat(starCount) * self.starSize)
                         / CGFloat(starCount - 1)
        
        self.ratingChangeEvent = ratingChangeEvent
        
        super.init(frame: frame)
        
        let label = UILabel()
        label.textAlignment = .center
        label.text = additionalText
        label.font = label.font.withSize(16)
        label.textColor = UIColor(red: 0.741, green: 0.741, blue: 0.741, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: textHeight),
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: self.starSize + padding),
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        self.additionalText = label
        
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .systemBackground
        
        if starCount > 0 {
            let button = createStarButton()

            addSubview(button)
            activate(button, regardingOn: self.leadingAnchor)
            button.tag = 1
            stars.append(button)
        }

        for i in 1..<self.starCount {
            let button = createStarButton()
            
            addSubview(button)
            activate(button, regardingOn: stars[i - 1].trailingAnchor, padding: self.starPadding)
            button.tag = i + 1
            stars.append(button)
        }
                
        NSLayoutConstraint.activate([
            stars[starCount - 1].trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    private func createStarButton() -> UIButton {
        let button = UIButton()
        
        button.setImage(UIImage(named: "Star.png"), for: .selected)
        button.setImage(UIImage(named: "StarNormal.png"), for: .normal)
        button.addTarget(self, action: #selector(rate), for: self.ratingChangeEvent)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }
    
    private func activate(_ button: UIButton, regardingOn: NSLayoutXAxisAnchor, padding: CGFloat = 0) {
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: self.topAnchor),
            button.widthAnchor.constraint(equalToConstant: self.starSize),
            button.heightAnchor.constraint(equalToConstant: self.starSize),
            button.leadingAnchor.constraint(equalTo: regardingOn, constant: padding)
        ])
    }
    
    required init(coder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    @objc func rate(pressedButton: UIButton) {
        let numberRating = pressedButton.tag
        
        for star in stars {
            star.isSelected = star.tag <= numberRating
        }
        
        if let rating = Rating(rawValue: numberRating) {
            self.rating = rating
        }
    }
}
