//
//  Notification.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 13/03/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import Foundation


class Notification {
    
    ///Дата создания уведомления
    var creationDate: Date!
    
    ///Идентификатор пользователя оставившего уведомление
//    var userID: String!
    
    ///Идентификатор поста для которого сделано уведомление
//    var postID: String?
    
    ///Тип уведомления
    var type: NotificationType!
    
    ///Информация о пользователе оставившего уведомление
    var user: User!
    
    ///Информация о посте для которого сделано уведомление
    var post: Post!
    
    ///Увидел ли текущий пользователь это уведомление
    var didCheck = false
    
    init(user: User, post: Post? = nil, dictionary: Dictionary<String, AnyObject>) {
        
        self.user = user
        
        if let post = post {
            self.post = post
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
        
        if let type = dictionary["type"] as? Int {
            self.type = NotificationType(index: type)
        }
        
        if let check = dictionary["checked"] as? Int {
            self.didCheck = check == 0 ? false : true
        }
        
        
    }
    
}
