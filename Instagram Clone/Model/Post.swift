//
//  Post.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 25/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.

import Foundation
import Firebase

class Post {
    ///Описание поста
    var description: String!
    ///Количество лайков
    var likes: Int!
    ///Путь к изображению поста
    var imageURL: String!
    ///Идентификатор пользователя который выложил пост
    var ownerID: String!
    ///Дата создания поста
    var creationDate: Date!
    ///Идентификатор поста
    var postID: String!
    ///Информация о пользователе опубликовавшем этот пост
    var user: User?
    ///Лайкнул ли пользователь этот пост
    var didLike = false
    
    init(postID: String, user: User, dictionary: Dictionary<String, AnyObject>) {
        
        self.postID = postID
        
        self.user = user
        
        if let description = dictionary["description"] as? String {
            self.description = description
        }
        
        if let like = dictionary["likes"] as? Int {
            self.likes = like
        }
        
        if let ownerId = dictionary["ownerID"] as? String {
            self.ownerID = ownerId
        }
        
        if let postImageURL = dictionary["postImageUrl"] as? String {
            self.imageURL = postImageURL
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
    
    /// Устанавливает или снимает лайк
    ///
    /// - Parameters:
    ///     - addLike: true - установить лайк, false - убрать лайк
    ///     - completion: Блок кода который нужно выполнить после работы с БД
    public func setLikes(addLike: Bool, completion: @escaping (Int) -> ()) {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        guard let postID = self.postID else { return }
        
        if addLike {
            
            //Добавляем информацию в таблицу user-likes
            USER_LIKES_REF.child(currentUserID).updateChildValues([postID : 1]) { (error, ref) in
                
                //Посылаем уведомление о лайке на сервер
                self.sendLikeNotificationToServer()
                
                //Добавляем информацию в таблицу post-likes
                POST_LIKES_REF.child(self.postID).updateChildValues([currentUserID : 1]) { (error, ref) in
                    self.likes += 1
                    self.didLike = true
                    //Обновляем информацию о количестве лайков поста
                    POSTS_REF.child(self.postID).child("likes").setValue(self.likes)
                    completion(self.likes)
                }
            }
        }
        else{
            guard likes > 0 else {return}
            
            //Перед тем как удалить информацию из таблицы user-likes, сначала нам надо удалить информацию из таблицы notifications
            USER_LIKES_REF.child(currentUserID).child(postID).observeSingleEvent(of: .value) { (dataFromDB) in
                
                //Получаем ID уведомления для текущего поста, чтобы удалить его
                guard let notificationID = dataFromDB.value as? String else {return}
                
                //Удаляем уведомление
                NOTIFICATONS_REF.child(self.ownerID).child(notificationID).removeValue(completionBlock: { (error, ref) in
                    
                    //А теперь мы удаляем информацию из таблицы user-likes
                    USER_LIKES_REF.child(currentUserID).child(postID).removeValue { (error, ref) in
                        //Удаляем информацию из таблицы post-likes
                        POST_LIKES_REF.child(self.postID).child(currentUserID).removeValue(completionBlock: { (error, ref) in
                            self.likes -= 1
                            self.didLike = false
                            //Обновляем информацию о количестве лайков поста
                            POSTS_REF.child(self.postID).child("likes").setValue(self.likes)
                            completion(self.likes)
                        })
                    }
                })
            }
        }
        
    }
    
    ///Посылает уведомление о лайке на сервер
    private func sendLikeNotificationToServer() {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else{return}
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        //Если пользователь лайкнул собственную публикацию то мы не будет уведомлять его об этом
        if currentUserID != self.ownerID {
            let values = ["checked" : 0,
                          "creationDate" : creationDate,
                          "userID" : currentUserID,
                          "type": NotificationType.Like.rawValue,
                          "postID" : postID] as Dictionary<String, Any>
            
            //Добавляем созданную информацию в таблицу Notifications
            let notificationRef = NOTIFICATONS_REF.child(self.ownerID).childByAutoId()
            notificationRef.updateChildValues(values) { (error, dataFromDB) in
                //Затем добавляем в таблицу user-likes к лайкнутому посту созданное уведомление по его ID
                USER_LIKES_REF.child(currentUserID).child(self.postID).setValue(notificationRef.key)
            }
        }
    }
    
}
