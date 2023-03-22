import UIKit

class FilmCell: UITableViewCell {
    
    private lazy var filmName: UILabel = {
        let label = UILabel()
        
        label.font = UIFont(name: "ArialRoundedMTBold", size: 30)
        
        return label
    }()
    
    private lazy var directorName: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        
        label.font = UIFont(name: "GillSans-Light", size: 20)
        
        return label
    }()
    
    private lazy var year: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        
        label.font = UIFont(name: "ArialHebrew-Light", size: 17)
        
        label.textColor = .systemGray
        
        return label
    }()
    
    private lazy var ratingBar: RatingBar = {
        let bar = RatingBar(frame: CGRect(x: 0, y: 0, width: 141, height: 25),
                            ratingChangeEvent: .touchDragInside)
        
        bar.translatesAutoresizingMaskIntoConstraints = false
        
        return bar
    }()
    
    public var film: String? {
        get { self.filmName.text }
        set { self.filmName.text = newValue }
    }
    
    // TODO: damn optional types
    
    public var director: String? {
        get { self.directorName.text }
        set { self.directorName.text = "Режиссёр: \(newValue ?? "")" }
    }
    
    // TODO: damn optional types
    
    public var date: String? {
        get { self.year.text }
        set { let separatedDate: [String] = newValue?.components(separatedBy: ".") ?? []
            self.year.text = "\(separatedDate[0]) \(monthMap[separatedDate[1]] ?? "") \(separatedDate[2])"
        }
    }
    
    public var rating: Rating {
        get { self.ratingBar.rating }
        set { self.ratingBar.rating = newValue }
    }
    
    private let monthMap: Dictionary<String, String> = [
        "01": "января", "02": "февраля", "03": "марта", "04": "апреля",
        "05": "мая", "06": "июня", "07": "июля", "08": "августа",
        "09": "сентября", "10": "октября", "11": "ноября", "12": "декабря",
    ]
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupView()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - SETUP VIEW

extension FilmCell {
    
    private func setupView() {
        [
            filmName,
            directorName,
            year,
            ratingBar
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            filmName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3),
            filmName.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            filmName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            filmName.heightAnchor.constraint(equalToConstant: 35),
            
            directorName.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            directorName.leadingAnchor.constraint(equalTo: filmName.leadingAnchor),
            directorName.heightAnchor.constraint(equalToConstant: 30),
            
            year.topAnchor.constraint(equalTo: filmName.bottomAnchor, constant: 5),
            year.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 26),
            year.heightAnchor.constraint(equalToConstant: 17),
            
            ratingBar.topAnchor.constraint(equalTo: filmName.bottomAnchor, constant: 3),
            ratingBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            ratingBar.heightAnchor.constraint(equalToConstant: ratingBar.frame.height),
        ])
    }
}
