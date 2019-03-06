//
//  Comment.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 01/03/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import Firebase

class Comment {
    
    ///Идентифкатор комментария
    var commentID: String!
    ///Текст комментария
    var commentText: String!
    ///Дата создания
    var creationDate: Date!
    ///Пользователь опубликовавший комментарий
    var user: User?
    
    init(commentID: String, user: User, dictionary: Dictionary<String, AnyObject>) {
        
        self.commentID = commentID
        self.user = user
        
        if let commentText = dictionary["commentText"] as? String {
            self.commentText = commentText
        }
        
        if let creationDate = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
}
