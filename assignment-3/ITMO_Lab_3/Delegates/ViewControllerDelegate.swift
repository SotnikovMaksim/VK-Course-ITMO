import UIKit

protocol ViewControllerDelegate: NSObject {
    func addFilm(film: String, director: String, date: String, rating: Rating)
}
