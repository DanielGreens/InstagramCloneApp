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
}
