//
//  Message.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 14/03/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import Foundation
import Firebase

class Message {
    
    // MARK: - Свойства
    
    ///Текст сообщения
    var messageText: String!
    ///От какого пользователя
    var fromUserID: String!
    ///Какому пользователю
    var toUserID: String!
    ///Дата сообщения
    var creationDate: Date!
    
    // MARK: - Инициализатор
    
    init(dictionary: Dictionary<String, AnyObject>) {
        
        if let text = dictionary["message"] as? String {
            self.messageText = text
        }
        
        if let from = dictionary["fromUserID"] as? String {
            self.fromUserID = from
        }
        
        if let to = dictionary["toUserID"] as? String {
            self.toUserID = to
        }
        
        if let date = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: date)
        }
    }
    
    // MARK: - Методы
    
    ///Получает данные о пользователе с которым идет переписка
    /// - Returns:
    ///     Возвращает идентификатор пользователя
    public func getChatPartnerData() -> String {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {return ""}
        
        //Если тот кто отправил сообщение есть текущий пользователь, то возвращаем информацию о том кому оно адресовано, чтобы получить соответствующую информацию, так как информацию о себе мы и так знаем
        if fromUserID == currentUserID {
            return toUserID
        }
        //Если отправил сообщение не текущий пользователь, то мы получаем информацию от кого оно пришло
        else {
            return fromUserID
        }
    }
}
