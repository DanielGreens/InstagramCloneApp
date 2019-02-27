//
//  Post.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 25/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.

import Foundation

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
    
    init(postID: String, dictionary: Dictionary<String, AnyObject>) {
        
        self.postID = postID
        
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
}
