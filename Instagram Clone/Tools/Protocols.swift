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
    func handleTapFollowButton(for cell: FollowLikeCell)
}

protocol FeedCellDelegate {
    
    ///Нажата кнопка имени пользователя
    func handleTapUsername(for cell: FeedCell)
    ///Нажата кнопка дополнительной информации о посте
    func handleTapOption(for cell: FeedCell)
    ///Нажата кнопка лайк
    func handleTapLike(for cell: FeedCell, isDoubleTap: Bool)
    ///Нажата кнопка комментариев
    func handleTapComment(for cell: FeedCell)
    ///Настройка отображения кнопки лайка (Лайкнут ли пост или нет)
    func handleConfigureLikeButton(for cell: FeedCell)
    ///Нажата надпись о количестве лайкнувших
    func handleTapLikeLabel(for cell: FeedCell)
}

protocol Printable {
    /// Описание для соответствующего значения перечисления
    var description: String { get }
}

protocol NotificationCellDelegate {
    
    ///Нажата кнопка Подписаться\Отписаться
    /// - Parameters:
    ///     - cell: Класс для которого обрабатывается нажатие
    func handleTapFollow(for cell: NotificationCell)
    
    ///Нажата иконка поста
    /// - Parameters:
    ///     - cell: Класс для которого обрабатывается нажатие
    func handleTapPost(for cell: NotificationCell)
}

protocol InputAccsesoryViewDelegate {
    
    ///Отправляет набранный пользователем текст на сервер
    /// - Parameters:
    ///     - text: Текст комментария
    func handleSendButton(forText text: String)
}
