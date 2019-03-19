//
//  NotificationVC.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 13/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "NotificationCell"

class NotificationVC: UITableViewController {
    
    // MARK: - Свойства
    
    ///Уведомления для пользователя
    var notifications = [Notification]()
    
    ///Идентификато последнего загруженного уведомления
    var lastLoadNotificationID: String?
    
    //Для устранения бага появления и кнопки и иконки поста в одном месте
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorColor = .clear
        
        navigationItem.title = "Уведомления"
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        fetchNotifications()
    }
    
    //Чтобы кнопка была корректной, потому что например на этом экране была кнопка подписаться, но мы подписались с другого экрана, и кнопка должна изменится на отписаться, но без этой функции этого не произойдет -> поэтому обновляем информацию
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        
        cell.notification = notifications[indexPath.row]
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let notification = notifications[indexPath.row]
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = notification.user
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if notifications.count > 14 {
            if indexPath.row == notifications.count - 1 {
                fetchNotifications()
            }
        }
    }
    
    // MARK: - Работа с Базой Данных
    
    ///Получает необходимые уведомления для текущего пользователя
    private func fetchNotifications() {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        //Первоначальная загрузка данных
        if lastLoadNotificationID == nil {
            NOTIFICATONS_REF.child(currentUserID).queryLimited(toLast: 15).observeSingleEvent(of: .value) { (dataFromDB) in
                
                guard let first = dataFromDB.children.allObjects.first as? DataSnapshot,
                    let allObjects = dataFromDB.children.allObjects as? [DataSnapshot] else {return}
                
                allObjects.forEach({ (data) in
                    
                    let notificationId = data.key
                    self.fetchNotification(dataSnapshot: data)
                    NOTIFICATONS_REF.child(currentUserID).child(notificationId).child("checked").setValue(1)
                })
                self.lastLoadNotificationID = first.key
            }
        }
        //Дополнительная порция данных
        else {
            NOTIFICATONS_REF.child(currentUserID).queryOrderedByKey().queryEnding(atValue: lastLoadNotificationID).queryLimited(toLast: 7).observeSingleEvent(of: .value) { (dataFromDB) in
                
                guard let first = dataFromDB.children.allObjects.first as? DataSnapshot,
                    let allObjects = dataFromDB.children.allObjects as? [DataSnapshot] else {return}
                
                allObjects.forEach({ (data) in
                    let notificationId = data.key
                    if self.lastLoadNotificationID != notificationId {
                        
                        self.fetchNotification(dataSnapshot: data)
                        NOTIFICATONS_REF.child(currentUserID).child(notificationId).child("checked").setValue(1)
                    }
                })
                self.lastLoadNotificationID = first.key
            }
        }
    }
    
    /// Извлекает необходимые данные связанные с уведомлением
    ///
    /// - Parameters:
    ///     - dataSnapshot: Данные полученные с сервера об уведомлении
    private func fetchNotification(dataSnapshot: DataSnapshot) {
        
        guard let dictionary = dataSnapshot.value as? Dictionary<String, AnyObject> else {return}
        guard let userID = dictionary["userID"] as? String else {return}
        
        Database.fetchUser(with: userID, completion: { (user) in
            //Если уведомление было типа Лайк или Комментарий, то мы получаем информацию о посте
            if let postID = dictionary["postID"] as? String {
                Database.fetchPost(with: postID, completion: { (post) in
                    let notification = Notification(user: user, post: post, dictionary: dictionary)
                    self.notifications.append(notification)
                    self.handleReloadTable()
                })
            }
                //Если уведомление было о новом подписчике, оно не содержит информацию о посте
            else {
                let notification = Notification(user: user, dictionary: dictionary)
                self.notifications.append(notification)
                self.handleReloadTable()
            }
        })
    }
    
    // MARK: - Обработка нажатия кнопок
    
    
    // MARK: - Вспомогательные функции
    
    ///Сортирует массив уведомление по дате
    @objc private func sortNotifications() {
        
        self.notifications.sort { (not1, not2) -> Bool in
            return not1.creationDate > not2.creationDate
        }
        
        self.tableView.reloadData()
    }

    private func handleReloadTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(sortNotifications), userInfo: nil, repeats: false)
    }
}

// MARK: - NotificationCellDelegate

extension NotificationVC : NotificationCellDelegate {
    
    func handleTapFollow(for cell: NotificationCell) {
        guard let user = cell.notification?.user else{return}
        
        if user.isFollowed {
            user.unfollow()
            cell.followButton.configureFollowButton(didFollow: true)
        }
        else {
            user.follow()
            cell.followButton.configureFollowButton(didFollow: false)
        }
    }
    
    func handleTapPost(for cell: NotificationCell) {
        
        guard let post = cell.notification?.post else {return}
        
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.viewSinglePost = true
        feedVC.post = post
        navigationController?.pushViewController(feedVC, animated: true)
    }
}
