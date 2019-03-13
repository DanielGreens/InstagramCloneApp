//
//  User.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 15/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//
import Firebase

class User {
    
    // MARK: - Свойства
    
    /// Уникальный идентификатор пользователя
    var userID: String!
    /// Никнейм пользователя
    var username: String!
    /// Имя пользователя
    var name: String!
    /// Адрес по которому хранится изображение пользователя
    var profileImageURL: String!
    /// Подписан ли текущий пользователь на выбранного пользователя
    var isFollowed = false
    
    // MARK: - Инициализатор
    
    /// Инициализатор класса User
    /// - Parameters:
    ///     - uid: Параметр
    ///     - dictionary: Словарь значений полученных из БД о пользователе
    init(uid: String, dictionary: Dictionary<String, AnyObject>) {
        self.userID = uid
        
        if let username = dictionary["username"] as? String {
            self.username = username
        }
        
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        
        if let imageURL = dictionary["profileImageUrl"] as? String {
            self.profileImageURL = imageURL
        }
    }
    
    // MARK: - Методы
    
    ///Функция добавляет текущему пользователю подписку, а пользователю на которого осуществлена подписка, добавляет нового подписчика
    func follow(){
        //ID текущего пользователя
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        //ID на который текущий пользователь хочет подписаться
        guard let userID = userID else { return }
        
        self.isFollowed = true
        
        //Добавляем подписку для currentUser в структуру user-following (Подписки пользователей)
        USER_FOLLOWING_REF.child(currentUserID).updateChildValues([userID: 1])
        
        //Добавляем для uid нового подписчика в структуру user-followers (Подписчики пользователей)
        USER_FOLLOWERS_REF.child(userID).updateChildValues([currentUserID: 1])
        
        //Добавляем уведомление о подписчике на сервер
        uploadFollowNotificationToServer()
        
        //Обновляем ленту новостей пользователя добавляя публикации новой подписки
        USER_POSTS_REF.child(userID).observe(.childAdded) { (dataFromDB) in
            
            let postID = dataFromDB.key
            USER_FEED_REF.child(currentUserID).updateChildValues([postID : 1])
        }
        
    }
    
    ///Функция удаляет у текущего пользователя подписку, а пользователю на которого подписка была отменена, удаляет этого подписчика
    func unfollow() {
        //ID текущего пользователя
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        //ID на который текущий пользователь хочет подписаться
        guard let userID = userID else { return }
        
        self.isFollowed = false
        
        //Удалчем у пользователя currentUid пользователя userID из подписок
        USER_FOLLOWING_REF.child(currentUid).child(userID).removeValue()
        //Удалчем у пользователя userID пользователя currentUid из подписчиков
        USER_FOLLOWERS_REF.child(userID).child(currentUid).removeValue()
        
        //Удаляем публикации пользователя от которого текущий пользователь отписался
        USER_POSTS_REF.child(userID).observe(.childAdded) { (dataFromDB) in
            
            let postID = dataFromDB.key
            USER_FEED_REF.child(currentUid).child(postID).removeValue()
        }
    }
    
    ///Проверяет подписан ли текущий пользователь на выбранного пользователя
    func checkIfUserIsFollowed(completion: @escaping (Bool) ->()) {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        
        USER_FOLLOWING_REF.child(currentUserID).observeSingleEvent(of: .value) { (dataFromDB) in

            //Если в таблице user-following для currentUserID есть поле с userID, то currentUserID подписан на userID
            if dataFromDB.hasChild(self.userID){
                self.isFollowed = true
                completion(true)
            }
            else{
                self.isFollowed = false
                completion(false)
            }
        }
    }
    
    ///Отправляет уведомление о новом подписчике на сервер
    private func uploadFollowNotificationToServer() {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        //Значение уведомления
        let values = ["checked" : 0,
                      "creationDate" : creationDate,
                      "userID" : currentUserID,
                      "type": NotificationType.Follow.rawValue] as Dictionary<String, Any>
        
        //Загружаем информацию на сервер, только если пользователь комментирует не свой пост
        NOTIFICATONS_REF.child(self.userID).childByAutoId().updateChildValues(values)
    }
    
    
    
}
