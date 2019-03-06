//
//  FollowVC.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 22/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "FollowCell"

class FollowLikeVC: UITableViewController {
    
    // MARK: - Свойства
    
    ///Режим просмотра текущего представления
    enum ViewingMode: Int {
        ///Смотрим подписчиков
        case Followers
        ///Смотрим подписки
        case Following
        ///Смотрим кто лайкнул пост
        case Likes
        
        init(index: Int) {
            switch index {
            case 0: self = .Followers
            case 1: self = .Following
            case 2: self = .Likes
            default: self = .Followers
            }
        }
    }
    
    ///Режим просмотра текущего представления
    var viewingMode: ViewingMode!
    ///Идентификатор поста для которого мы хотим просмотреть лайкнувших пользователей (Для режима .Likes)
    var postID: String?
    ///Идентификатор пользователя
    var userID: String?
    ///Массив пользователей
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(FollowLikeCell.self, forCellReuseIdentifier: reuseIdentifier)
        //Настриваем раззделители ячеек, чтобы разделение начиналось когда заканчивается аватар пользователя
        //64 слева, потому что размер аватарки 48, и плюс по 8 с двух краев для симметрии
        tableView.separatorColor = .clear
        
        guard let viewingMode = self.viewingMode else {return}
        
        configureNavigationBarTitle(by: viewingMode)
        
        fetchUsers(by: viewingMode)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FollowLikeCell
        
        cell.delegate = self
        cell.user = users[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[indexPath.row]
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = user
        
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    // MARK: - Работа с БД
    
    ///Получает необходимый список пользователей в зависимости от режима просмотра экрана
    /// - Parameters:
    ///     - viewingMode: Режима просмотра экрана
    private func fetchUsers(by viewingMode: ViewingMode) {
        guard let ref = getDatabaseReference() else {return}
        
        switch viewingMode {
        case .Followers, .Following:
            guard let userID = self.userID else {return}
            //Получаем ID подписчиков или подписок
            ref.child(userID).observeSingleEvent(of: .value) { (dataFromDB) in
                
                guard let allObjects = dataFromDB.children.allObjects as? [DataSnapshot] else {return}
                
                allObjects.forEach({ (data) in
                    let uid = data.key
                    self.fetchUser(with: uid)
                })
            }
        case .Likes:
            guard let postId = postID else {return}
            ref.child(postId).observe(.childAdded) { (dataFromDB) in
                
                let userID = dataFromDB.key
                self.fetchUser(with: userID)
            }
        }
    }
    
    ///Возвращает ссылку на нужную таблицу в БД в зависимости от типа просмотра экрана
    /// - Parameters:
    ///     - viewingMode: Режима просмотра экрана
    private func getDatabaseReference() -> DatabaseReference? {
        guard let viewingMode = self.viewingMode else {return nil}
        
        switch viewingMode {
        case .Followers: return USER_FOLLOWERS_REF
        case .Following: return USER_FOLLOWING_REF
        case .Likes: return POST_LIKES_REF
        }
    }
    
    ///Получает данные о пользователе по его идентифкатору
    /// - Parameters:
    ///     - userID: Идентификатор пользователя
    private func fetchUser(with userID: String){
        Database.fetchUser(with: userID, completion: { (user) in
            self.users.append(user)
            self.tableView.reloadData()
        })
    }
    
    // MARK: - Вспомогательные функции
    
    private func configureNavigationBarTitle(by viewingMode: ViewingMode) {
        switch viewingMode {
        case .Followers: navigationItem.title = "Подписчики"
        case .Following: navigationItem.title = "Подписки"
        case .Likes: navigationItem.title = "Отметки Нравится"
        }
    }
}

// MARK: - Реализация протокола FollowCellDelegate

extension FollowLikeVC : FollowCellDelegate {
    
    func handleTapFollowButton(for cell: FollowLikeCell) {
        
        guard let user = cell.user else{return}
        
        if user.isFollowed {
            user.unfollow()
            cell.followButton.setTitle("Подписаться", for: .normal)
            cell.followButton.setTitleColor(.white, for: .normal)
            cell.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            cell.followButton.layer.borderWidth = 0
        }
        else {
            user.follow()
            cell.followButton.setTitle("Отписаться", for: .normal)
            cell.followButton.setTitleColor(.black, for: .normal)
            cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.followButton.layer.borderWidth = 0.5
            cell.followButton.backgroundColor = .white
        }
    }
    
}