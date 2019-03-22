//
//  SearchVC.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 13/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

///Идентификатор ячейки таблицы
private let reuseIdentifier = "SearchUserCell"

class SearchVC: UITableViewController, UISearchBarDelegate {
    
    // MARK: - Свойства
    ///Все полученные из БД пользователи
    var users = [User]()
    ///Строка поиска
    var searchBar = UISearchBar()
    ///Пользователи удовлетворяющие поиску
    var filteresUsers = [User]()
    ///Ищет ли пользотваель
    var isSearchMode = false
    ///Отображение картинок постов
    var collectionView: UICollectionView!
    ///Отображать фото постов или нет
    var collectionViewEnabled = true
    ///Фотографии постов
    var posts = [Post]()
    ///Идентификато последнего загруженного поста
    var lastLoadPostID: String?
    ///Идентификато последнего загруженного пользователя
    var lastLoadUserID: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        //Регестрируем Ячейку на наш класс SearchUserCell
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        //Настриваем раззделители ячеек, чтобы разделение начиналось когда заканчивается аватар пользователя
        //64 слева, потому что размер аватарки 48, и плюс по 8 с двух краев для симметрии
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
        
        //Настраиваем контроль обновления ленты
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        configureSearchBar()
        
        configureCollectionView()
        
        fetchPosts()
        
        fetchUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchMode {
            return filteresUsers.count
        }
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchUserCell
        
        if isSearchMode {
            cell.user = filteresUsers[indexPath.row]
        }
        else {
            cell.user = users[indexPath.row]
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var user: User
        if isSearchMode {
            user = filteresUsers[indexPath.row]
        }
        else {
            user = users[indexPath.row]
        }
        
        //Создаем страницу с пользователем на которого кликнули
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        //Передаем данные о выбранном пользователе в UserProfileVC
        userProfileVC.user = user
        
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if posts.count > 17 {
            if indexPath.row == posts.count - 1 {
                fetchPosts()
            }
        }
    }
    
    // MARK: - UISearchBar
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        
        collectionView.isHidden = true
        collectionViewEnabled = false
        tableView.separatorColor = .lightGray
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let searchText = searchText.lowercased()
        
        if searchText.isEmpty || searchText == " " {
            isSearchMode = false
            tableView.reloadData()
        }
        else {
            isSearchMode = true
            filteresUsers = users.filter({ (user) -> Bool in
                return user.username.contains(searchText)
            })
            tableView.reloadData()
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.text = nil
        isSearchMode = false
        collectionViewEnabled = true
        collectionView.isHidden = false
        tableView.separatorColor = .clear
        tableView.reloadData()
    }
    
    // MARK: - Настройка внешнего вида окна
    
    ///Настраиваем панель навигации
    private func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        searchBar.barTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        searchBar.tintColor = .black
    }
    
    // MARK: - Работа с Базой данных
    
    ///Загружает данные о пользователях из БД
    private func fetchUsers() {
        //Первоначальная загрузка данных
        if lastLoadUserID == nil {
            USER_REF.queryLimited(toLast: 12).observeSingleEvent(of: .value) { (dataFromDB) in
                
                guard let first = dataFromDB.children.allObjects.first as? DataSnapshot,
                    let allObjects = dataFromDB.children.allObjects as? [DataSnapshot] else {return}
                
                allObjects.forEach({ (data) in
                    let userID = data.key
                    self.fetchUser(with: userID)
                })
                self.lastLoadUserID = first.key
            }
        }
        //Дополнительная порция данных
        else {
            USER_REF.queryOrderedByKey().queryEnding(atValue: lastLoadPostID).queryLimited(toLast: 7).observeSingleEvent(of: .value) { (dataFromDB) in
                
                guard let first = dataFromDB.children.allObjects.first as? DataSnapshot,
                    let allObjects = dataFromDB.children.allObjects as? [DataSnapshot] else {return}
                
                allObjects.forEach({ (data) in
                    if data.key != self.lastLoadPostID {
                        self.fetchUser(with: data.key)
                    }
                })
                self.lastLoadUserID = first.key
            }
        }
    }
    
    ///Загружаем фото всех постов
    private func fetchPosts() {
        
        //Первоначальная загрузка данных
        if lastLoadPostID == nil {
            POSTS_REF.queryLimited(toLast: 18).observeSingleEvent(of: .value) { (dataFromDB) in
                
                guard let first = dataFromDB.children.allObjects.first as? DataSnapshot,
                    let allObjects = dataFromDB.children.allObjects as? [DataSnapshot] else {return}
                
                self.tableView.refreshControl?.endRefreshing()
                
                allObjects.forEach({ (data) in
                    let postID = data.key
                    self.fetchPost(with: postID)
                })
                self.lastLoadPostID = first.key
            }
        }
        //Дополнительная порция данных
        else {
            POSTS_REF.queryOrderedByKey().queryEnding(atValue: lastLoadPostID).queryLimited(toLast: 7).observeSingleEvent(of: .value) { (dataFromDB) in
                
                guard let first = dataFromDB.children.allObjects.first as? DataSnapshot,
                    let allObjects = dataFromDB.children.allObjects as? [DataSnapshot] else {return}
                
                allObjects.forEach({ (data) in
                    if data.key != self.lastLoadPostID {
                        self.fetchPost(with: data.key)
                    }
                })
                self.lastLoadPostID = first.key
            }
        }
    }
    
    /// Загружает данные о публикации
    ///
    /// - Parameters:
    ///     - postID: Идентификатор загружаемого поста
    private func fetchPost(with postID: String) {
        Database.fetchPost(with: postID, completion: { (post) in
            self.posts.append(post)
            
            //Сортируем посты по дате создания (Старые посты в конец, новые вперед)
            self.posts.sort(by: { (post1, post2) -> Bool in
                return post1.creationDate > post2.creationDate
            })
            
            self.collectionView.reloadData()
        })
    }
    
    ///Загружает информацию о пользователе
    /// - Parameters:
    ///     - userID: Идентификатор пользователя, информацию о котором нужно загрузить
    private func fetchUser(with userID: String) {
        Database.fetchUser(with: userID) { (user) in
            self.users.append(user)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Вспомогательные функции
    
    ///Обновляем данные экрана
    @objc public func handleRefresh() {
        posts.removeAll()
        lastLoadPostID = nil
        fetchPosts()
        collectionView.reloadData()
    }

}

// MARK: - UICollectionView

private let reuseIdentifierPostCell = "SearchPostCell"

extension SearchVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private func configureCollectionView() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        //Рамка, где будет отображаться коллекция фото постов
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - (tabBarController?.tabBar.frame.height)! - (navigationController?.navigationBar.frame.height)!)
        
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        tableView.addSubview(collectionView)
        collectionView.register(SearchPostCell.self, forCellWithReuseIdentifier: reuseIdentifierPostCell)
        tableView.separatorColor = .clear
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierPostCell, for: indexPath) as! SearchPostCell
        
        cell.post = posts[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.viewSinglePost = true
        feedVC.post = posts[indexPath.item]
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if users.count > 11 {
            if indexPath.item == users.count - 1{
                fetchUsers()
            }
        }
    }
}
