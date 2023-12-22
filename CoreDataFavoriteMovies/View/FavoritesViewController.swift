//
//  FavoritesViewController.swift
//  CoreDataFavoriteMovies
//
//  Created by Parker Rushton on 11/3/22.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var backgroundView: UIView!
    
    let movieController = MovieController.shared
    var dataSource: UITableViewDiffableDataSource<Int, Movie>!
    var viewContext = PersistenceController.shared.viewContext
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search Favorites"
        sc.searchBar.delegate = self
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        setUpDataSource()
        navigationItem.searchController = searchController
        fetchFavorites()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchFavorites()
    }
    
}

private extension FavoritesViewController {
    
    func setUpTableView() {
        tableView.backgroundView = backgroundView
        tableView.register(UINib(nibName: MovieTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: MovieTableViewCell.reuseIdentifier)
    }
    
    func setUpDataSource() {
        dataSource = UITableViewDiffableDataSource<Int, Movie>(tableView: tableView) { tableView, indexPath, movie in
            let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier) as! MovieTableViewCell
            cell.update(with: movie) {
                self.removeFavorite(movie)
            }
            return cell
        }
    }
    
    func applyNewSnapshot(from movies: [Movie]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Movie>()
        snapshot.appendSections([0])
        snapshot.appendItems(movies)
        dataSource.apply(snapshot, animatingDifferences: true)
        tableView.backgroundView = movies.isEmpty ? backgroundView : nil
    }
    
    func fetchFavorites() {
        let fetchRequest = Movie.fetchRequest()
        let searchText = searchController.searchBar.text ?? ""
        if !searchText.isEmpty {
            let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchText)
            fetchRequest.predicate = predicate
        }
        let results = try? viewContext.fetch(fetchRequest)
        applyNewSnapshot(from: results ?? [])
    }
    
    func removeFavorite(_ movie: Movie) {
        movieController.unfavoriteMovie(movie)
        var snapshot = dataSource.snapshot()
        snapshot.deleteItems([movie])
        dataSource?.apply(snapshot, animatingDifferences: true)
    }

    
}

extension FavoritesViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text?.isEmpty == true {
            fetchFavorites()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchFavorites()
    }
}
