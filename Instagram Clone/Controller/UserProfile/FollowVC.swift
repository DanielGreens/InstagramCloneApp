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

class FollowVC: UITableViewController {
    
    // MARK: - Свойства
    
    var viewFollowers = false
    var viewFollow = false
    var userID: String?
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(FollowCell.self, forCellReuseIdentifier: reuseIdentifier)
        //Настриваем раззделители ячеек, чтобы разделение начиналось когда заканчивается аватар пользователя
        //64 слева, потому что размер аватарки 48, и плюс по 8 с двух краев для симметрии
        tableView.separatorColor = .clear
        
        fetchUsers()
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FollowCell
        
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
    
    private func fetchUsers() {
        
        guard let userID = self.userID else {return}
        
        var ref: DatabaseReference!
        
        if viewFollowers {
            ref = USER_FOLLOWERS_REF
        }
        else{
            ref = USER_FOLLOWING_REF
        }
        
        //Получаем ID подписчиков или подписок
        ref.child(userID).observeSingleEvent(of: .value) { (dataFromDB) in
            
            guard let allObjects = dataFromDB.children.allObjects as? [DataSnapshot] else {return}
            
            allObjects.forEach({ (data) in
                let uid = data.key
                //Получаем данные о пользователе по полученным ID
                Database.fetchUser(with: uid, completion: { (user) in
                    self.users.append(user)
                    self.tableView.reloadData()
                })
            })
        }
    }
}

// MARK: - Реализация протокола FollowCellDelegate

extension FollowVC : FollowCellDelegate {
    
    func handleTapFollowButton(for cell: FollowCell) {
        
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
