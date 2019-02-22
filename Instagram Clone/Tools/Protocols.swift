//
//  Protocols.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 22/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import Foundation


protocol UserProfileHeaderDelegate {
    
    ///Нажата кнопка Редактировать профиль или Подписаться / Отписаться от пользователя
    /// - Parameters:
    ///     - header: Класс для которого обрабатывается нажатие
    func handleTapEditProfileOrFollow(for header: UserProfileHeader)
    
    /// Получает информацию о кличестве постов, подписчиков и подписок пользователя
    ///
    /// - Parameters:
    ///     - header: Класс для которого происходит действие
    func setUserStats(for header: UserProfileHeader, with userID: String)
    
    ///Нажата надпись о количестве подписчиков
    /// - Parameters:
    ///     - header: Класс для которого обрабатывается нажатие
    func handleTapFollowers(for header: UserProfileHeader)
    
    ///Нажата надпись о количестве подписок
    /// - Parameters:
    ///     - header: Класс для которого обрабатывается нажатие
    func handleTapFollow(for header: UserProfileHeader)
}


protocol FollowCellDelegate {
    
    ///Обработка нажатия кнопки Подписаться / Отписаться
    func handleTapFollowButton(for cell: FollowCell)
}
