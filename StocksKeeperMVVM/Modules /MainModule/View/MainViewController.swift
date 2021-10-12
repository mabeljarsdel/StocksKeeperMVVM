//
//  MainViewController.swift
//  StocksKeeperMVVM
//
//  Created by dev on 8.10.21.
//

import UIKit

class MainViewController: UIViewController {
    var viewModel: MainViewModelProtocol!
    
    private var searchBar = SearchBar()
    private var bookmarkedStocksTableView = BookmarkedStocksTableView.makeTableView()
    
    var bookmarks: [Stock]!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bookmarks = viewModel.fetchBookmarks()
        configureSearchBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    func setup() {
        view.backgroundColor = .white
        configureTabBar()
        configureSearchBar()
        configureBookmarksTableView()
    }
    
    func configureTabBar() {
        tabBarItem = UITabBarItem(title: "Favorites",
                                  image: UIImage(systemName: "star"),
                                  selectedImage: UIImage(systemName: "star.fill"))
        tabBarController?.tabBar.tintColor = .black
        navigationController?.navigationBar.tintColor = .black
        title = "Favorites"
    }
    
    func configureSearchBar() {
        initiateSearch(false)
        searchBar.showsCancelButton = false
        searchBar.text = ""
        searchBar.delegate = self
        navigationItem.rightBarButtonItem = (UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"),
                                                             style: .plain,
                                                             target: self,
                                                             action: #selector(searchButtonTapped(sender:))))
    }
    
    func configureBookmarksTableView() {
        bookmarkedStocksTableView.register(UITableViewCell.self, forCellReuseIdentifier: "bookMarkCell")
        bookmarkedStocksTableView.delegate = self
        bookmarkedStocksTableView.dataSource = self
        
        view.addSubview(bookmarkedStocksTableView)
        bookmarkedStocksTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bookmarkedStocksTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bookmarkedStocksTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bookmarkedStocksTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    func initiateSearch(_ check: Bool) {
        if check {
            searchBar.searchTableView.delegate = self
            searchBar.searchTableView.dataSource = self
            
            searchBar.searchTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            
            searchBar.searchTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
            
            view.addSubview(searchBar.searchTableView)
            searchBar.searchTableView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                searchBar.searchTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                searchBar.searchTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                searchBar.searchTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
            ])
        } else {
            if view.subviews.contains(searchBar.searchTableView) {
                view.willRemoveSubview(searchBar.searchTableView)
                searchBar.searchTableView.removeFromSuperview()
                navigationItem.titleView = nil
            }
        }
    }
    
    func updateView() {
        viewModel.updateViewData = { [weak self] viewData in
            self?.searchBar.viewData = viewData
        }
    }
    
    @objc func searchButtonTapped(sender: UIButton) {
        initiateSearch(true)
        navigationItem.titleView = searchBar
        searchBar.showsCancelButton = true
        searchBar.becomeFirstResponder()
        navigationItem.rightBarButtonItem = nil
    }
    
    func fetchBookMarks() {
        bookmarks = viewModel.fetchBookmarks()
    }
}

//MARK: - SearchBarDelegate
extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.startFetch(withSymbol: searchText)
        updateView()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        initiateSearch(false)
        configureSearchBar()
        searchBar.resignFirstResponder()
    }
}

//MARK: - TableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === searchBar.searchTableView {
            let detailedController = (UIApplication.shared.delegate as! AppDelegate).router.createDetailedStockModule(withSymbol: searchBar.companies[indexPath.row].symbol ?? "AAPL")
            navigationController?.pushViewController(detailedController, animated: true)
        } else if tableView === bookmarkedStocksTableView {
            let detailedController = (UIApplication.shared.delegate as! AppDelegate).router.createDetailedStockModule(withSymbol: bookmarks[indexPath.row].symbol ?? "AAPL")
            navigationController?.pushViewController(detailedController, animated: true)
        }
    }
}

//MARK: - TableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === searchBar.searchTableView {
            return searchBar.companies.count
        } else if tableView === bookmarkedStocksTableView {
            return bookmarks.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === searchBar.searchTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            cell?.textLabel?.text = searchBar.companies[indexPath.row].name
            return cell!
        } else if tableView === bookmarkedStocksTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "bookMarkCell")
            cell?.textLabel?.text = bookmarks[indexPath.row].name
            return cell!
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "cell")!
        }
    }
}
