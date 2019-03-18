//
//  Database-Extension.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 22/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import Firebase

extension Database {
    
    ///Загружает информацию о пользователе
    /// - Parameters:
    ///     - userID: Идентификатор пользователя, информация о котором нужно загрузить
    ///     - completion: Блок кода который вызывается после отработки метода
    static func fetchUser(with userID: String, completion: @escaping(User) -> ()){
        
        USER_REF.child(userID).observeSingleEvent(of: .value) { (dataFromDB) in
            
            guard let dictionary = dataFromDB.value as? Dictionary<String, AnyObject> else {return}
            
            let user = User(uid: userID, dictionary: dictionary)
            
            completion(user)
        }
    }
    
    /// Загружает данные о публикации
    ///
    /// - Parameters:
    ///     - postID: Идентификатор загружаемого поста
    ///     - completion: Метод который отработает после загрузки необходимых данных
    static func fetchPost(with postID: String, completion: @escaping (Post) -> ()) {
        
        POSTS_REF.child(postID).observeSingleEvent(of: .value) { (dataFromDB) in
            
            guard let dictionary = dataFromDB.value as? Dictionary<String, AnyObject> else {return}
            guard let ownerID = dictionary["ownerID"] as? String else {return}
            
            Database.fetchUser(with: ownerID, completion: { (user) in
                
                let post = Post(postID: postID, user: user, dictionary: dictionary)
                completion(post)
            })
        }
    }
    
    /// Загружает данные о конкретном сообщении
    ///
    /// - Parameters:
    ///     - messageID: Идентификатор загружаемого сообщения
    ///     - completion: Метод который отработает после загрузки необходимых данных
    static func loadMessage(with messageID: String, completion: @escaping (Message) -> ()) {
        
        MESSAGES_REF.child(messageID).observeSingleEvent(of: .value) { (dataFromDB) in
            
            guard let dictionary = dataFromDB.value as? Dictionary<String, AnyObject> else {return}
            
            let message = Message(dictionary: dictionary)
            completion(message)
        }
    }
}
