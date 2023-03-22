import UIKit

class FilmlListController: UIViewController {
    private struct Film {
        let director: String
        let name: String
        let date: String
        let rating: Rating
    }
    
    private var years: [String] = ["1998", "1999", "2000"]
    
    private var films: [[Film]] = []
    
    private lazy var refresher: UIRefreshControl = {
        let refresher = UIRefreshControl()

        refresher.addTarget(FilmlListController.self, action: #selector(shuffle), for: .valueChanged)

        return refresher
    }()
    
    private lazy var table: UITableView = {
        let tableView = UITableView()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FilmCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 100
        tableView.sectionHeaderHeight = 20
        tableView.backgroundColor = .systemBackground
        tableView.sectionIndexBackgroundColor = .systemGray

        return tableView
    }()
    
    private lazy var addButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Добавить", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 24
        button.backgroundColor = UIColor(red: 0.366, green: 0.692, blue: 0.457, alpha: 1)
        button.layer.shadowOpacity = 0.7
        button.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        button.layer.shadowRadius = 15.0
        button.layer.shadowColor = UIColor.systemGray3.cgColor
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addBaseFilms()
        self.setupView()
    }
}

// MARK: - Controller setup

extension FilmlListController {
    private func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(self.table)
        
        self.table.refreshControl = refresher
//        self.table.refreshControl?.addTarget(self, action: #selector(shuffle), for: .valueChanged)
        
        ///     Section index setup
        self.table.sectionIndexBackgroundColor = .systemBackground
        self.table.sectionIndexColor = .systemGray
        self.table.sectionIndexMinimumDisplayRowCount = 5
        
        view.addSubview(self.addButton)
        
        NSLayoutConstraint.activate([
            self.table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.table.topAnchor.constraint(equalTo: view.topAnchor),
            self.table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            self.addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            self.addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            self.addButton.widthAnchor.constraint(equalToConstant: 340),
            self.addButton.heightAnchor.constraint(equalToConstant: 50),
        ])
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func addBaseFilms() {
        self.films = [
            [Film(director: "Gérard Pirès", name: "Taxi", date: "8.04.1998", rating: .amazing)],
            [Film(director: "Someone", name: "Some Film", date: "9.05.1999", rating: .normal)],
            [Film(director: "Stanger", name: "Another Film", date: "1.01.2000", rating: .good)],
        ]
    }
}

// MARK: - Adding film

extension FilmlListController: ViewControllerDelegate {
    func addFilm(film: String, director: String, date: String, rating: Rating) {
        if self.collision(film, director) {
            return
        }
        
        let year = date.components(separatedBy: ".")[2]
        
        guard let yearIndex = years.findUpperBoundIndex(of: year) else {
            let temp = self.years.count
            
            self.films.append([Film(director: director,
                                    name: film,
                                    date: date,
                                    rating: rating)])
            
            self.years.append(year)
            self.table.insertSections(IndexSet(integer: temp), with: .middle)

            return
        }
        
        if self.years[yearIndex] == year {
            self.films[yearIndex].append(Film(director: director,
                                              name: film,
                                              date: date,
                                              rating: rating))
            self.table.insertRows(at: [IndexPath(row: self.films[yearIndex].count - 1,
                                                 section: yearIndex)], with: .middle)
        } else {
            self.films.insert([Film(director: director,
                                    name: film,
                                    date: date,
                                    rating: rating)],
            at: yearIndex)
            self.years.insert(year, at: yearIndex)
            self.table.insertSections(IndexSet(integer: yearIndex), with: .middle)
        }
    }
    
    private func collision(_ film: String, _ director: String) -> Bool {
        return self.films.flatMap { $0 }.reduce(false) { $0 || ($1.name == film) }
            && self.films.flatMap { $0 }.reduce(false) { $0 || ($1.director == director) }
    }
}

// MARK: - Delete cell swipe action. Custom header

extension FilmlListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let removeAction = UIContextualAction(style: .destructive, title: .none) {
            _, _, _ in
            
            let section = indexPath.section
            let row = indexPath.row
            
            if self.films[section].count == 1 {
                self.years.remove(at: section)
                self.films.remove(at: section)
                self.table.deleteSections(IndexSet(integer: section), with: .left)
            } else {
                self.films[section].remove(at: row)
                self.table.deleteRows(at: [IndexPath(row: row, section: section)], with: .left)
            }
        }
        
        removeAction.image = UIImage(named: "rsz_trashbin")
        
        return UISwipeActionsConfiguration(actions: [removeAction])
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
        let yearTitle = UILabel()
        
        headerContainer.addSubview(yearTitle)
        headerContainer.backgroundColor = .systemBackground
        yearTitle.text = self.years[section]
        yearTitle.font = UIFont(name: "AvenirNext-Medium", size: 25)
        yearTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            yearTitle.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 3),
            yearTitle.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            yearTitle.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        return headerContainer
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        30
    }
}

// MARK: - Reusing cell. Setup sections and cells count.

extension FilmlListController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.years.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.films[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.years[section]
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.years
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        guard let index = self.years.firstIndex(of: title) else {
            return 0
        }
        return index
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? FilmCell else {
            return FilmCell()
        }
        
        let section = indexPath.section
        let row = indexPath.row
        
        cell.film = self.films[section][row].name
        cell.director = self.films[section][row].director
        cell.date = self.films[section][row].date
        cell.rating = self.films[section][row].rating
        cell.selectionStyle = .none
        
        return cell
    }
}
        
// MARK: - Pop up view controller of adding film screen

extension FilmlListController {
    @objc
    private func addButtonTapped() {
        let vc = ViewController()
        vc.delegate = self
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Unlock swipe right to get back

extension FilmlListController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - MOD

extension FilmlListController {
    @objc
    private func shuffle() {
        self.films.shuffle()
        self.years.shuffle()
        
        self.table.refreshControl?.endRefreshing()
    }
}
