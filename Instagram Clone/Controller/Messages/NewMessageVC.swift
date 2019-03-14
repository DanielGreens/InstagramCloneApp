//
//  NewMessageVC.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 14/03/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "NewMessageCell"

class NewMessageVC: UITableViewController {
    
    // MARK: - Свойства
    
    ///Подписчики пользователя
    var users = [User]()
    ///Родительский экран
    var parentVC: MessagesVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(NewMessageCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        configureNavigationBar()
        
        fetchUsers()
    }
    
    // MARK: - TableViewDataSource
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NewMessageCell
        
        cell.user = users[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.parentVC?.showChatVC(with: user)
        }
    }
    
    // MARK: - Настройка внешнего вида окна
    
    ///Настраивает панель навигации
    private func configureNavigationBar() {
        
        navigationItem.title = "Новый диалог"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleTapCancelButton))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    // MARK: - Работа с БД
    
    ///Получает подписчиков пользователей
    private func fetchUsers() {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else{return}
        
        USER_FOLLOWERS_REF.child(currentUserID).observe(.childAdded) { (dataFromDB) in
            
            let followerID = dataFromDB.key
            
            Database.fetchUser(with: followerID, completion: { (user) in
                self.users.append(user)
                self.tableView.reloadData()
            })
        }
        
    }
    
    // MARK: - Обработчики нажатий
    
    ///Закрывает текущий экран
    @objc private func handleTapCancelButton() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
