//
//  User.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 15/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

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
    
    // MARK: - Инициализаторы
    
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
    
    
    
}
