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

    override func viewDidLoad() {
        super.viewDidLoad()

        //Регестрируем Ячейку на наш класс SearchUserCell
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        //Настриваем раззделители ячеек, чтобы разделение начиналось когда заканчивается аватар пользователя
        //64 слева, потому что размер аватарки 48, и плюс по 8 с двух краев для симметрии
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
        
        configureSearchBar()
        
        configureCollectionView()
        
        fetchPosts()
        
        fetchUsers()
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
        
        USER_REF.observe(.childAdded) { (dataFromDB) in
            //Этот блок вызывается для каждого пользователя
            
            guard let dictionary = dataFromDB.value as? Dictionary<String, AnyObject> else {return}
            //Уникальный идентификатор пользователя
            let uid = dataFromDB.key
            
            let user = User(uid: uid, dictionary: dictionary)
            
            self.users.append(user)
            self.tableView.reloadData()
        }
    }
    
    ///Загружаем фото всех постов
    private func fetchPosts() {
        
        posts.removeAll()
        
        POSTS_REF.observe(.childAdded) { (dataFromDB) in
            
            let postID = dataFromDB.key
            
            Database.fetchPost(with: postID, completion: { (post) in
                
                self.posts.append(post)
                self.collectionView.reloadData()
            })
        }
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
    
}
