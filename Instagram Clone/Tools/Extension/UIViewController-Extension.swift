//
//  UIViewController-Extension.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 18/03/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

extension UIViewController {
    
    /// Возвращает данные об упомянутом пользователе
    /// - Parameters:
    ///     - userName: Имя упомянутого пользователя
    func getMentionedUser(with userName: String) {
        
        USER_REF.observe(.childAdded) { (dataFromDB) in
            let userID = dataFromDB.key
            
            guard let dictionary = dataFromDB.value as? Dictionary<String, AnyObject> else {return}
            
            if userName == dictionary["username"] as? String {
                Database.fetchUser(with: userID, completion: { (user) in
                    
                    let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
                    userProfileVC.user = user
                    self.navigationController?.pushViewController(userProfileVC, animated: true)
                    return
                })
            }
        }
    }
    
    /// Отправляет уведомление об упоминании пользователя на сервер
    /// - Parameters:
    ///     - postID: Идентификатор поста, который комментировали
    ///     - text: Текст комментария
    ///     - notificationType: Тип отправляемого уведомления
    func uploadMentionsNotification(for postID: String, with text: String, notificationType: NotificationType) {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        let creationDate = Int(NSDate().timeIntervalSince1970)
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        
        for var word in words {
            if word.hasPrefix("@") {
                word = word.trimmingCharacters(in: .symbols)
                word = word.trimmingCharacters(in: .punctuationCharacters)
                
                USER_REF.observe(.childAdded) { (dataFromDB) in
                    let userID = dataFromDB.key
                    
                    guard let dictionary = dataFromDB.value as? Dictionary<String, AnyObject> else {return}
                    
                    ///Если упомянутый пользователь найден, то создаем уведомление
                    if word == dictionary["username"] as? String {
                        
                        let notificationValues = ["checked" : 0,
                                                  "creationDate" : creationDate,
                                                  "userID" : currentUserID,
                                                  "type": notificationType.rawValue,
                                                  "postID" : postID] as Dictionary<String, Any>
                        
                        if currentUserID != userID {
                            NOTIFICATONS_REF.child(userID).childByAutoId().updateChildValues(notificationValues)
                        }
                    }
                }
            }
        }
    }
}
