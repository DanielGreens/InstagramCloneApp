//
//  Constants.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 22/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import Firebase

// MARK: - Ссылки на корневые узлы Базы Данных

/// Корневой узел БД
let DB_REF = Database.database().reference()
/// Корневой узел Хранилища изображений
let STORAGE_REF = Storage.storage().reference()

// MARK: - Ссылки на необходимые места в Хранилище

/// Ссылка на хранилище пользовательских изображений
let STORAGE_PROFILE_IMAGES_REF = STORAGE_REF.child("profile_images")
/// Ссылка на хранилище пользовательских изображений
let STORAGE_POST_IMAGES_REF = STORAGE_REF.child("post_images")


// MARK: - Ссылки на необходимые таблицы в БД

/// Ссылка на данные о Пользователях
let USER_REF = DB_REF.child("users")
/// Ссылка на таблицу подписок для пользователя
let USER_FOLLOWING_REF = DB_REF.child("user-following")
/// Ссылка на таблицу подписчиков пользователя
let USER_FOLLOWERS_REF = DB_REF.child("user-followers")
/// Ссылка на таблицу данных о постах
let POSTS_REF = DB_REF.child("posts")
/// Ссылка на таблицу постов пользователей
let USER_POSTS_REF = DB_REF.child("user-posts")
/// Ссылка на таблицу - ленту новостей для пользователей
let USER_FEED_REF = DB_REF.child("user-feed")
/// Ссылка на таблицу - какой пользователь какие посты лайкнул
let USER_LIKES_REF = DB_REF.child("user-likes")
/// Ссылка на таблицу - кто лайкнул какой пост
let POST_LIKES_REF = DB_REF.child("post-likes")
/// Ссылка на таблицу комментариев
let COMMENTS_REF = DB_REF.child("comments")
/// Ссылка на таблицу комментариеы
let NOTIFICATONS_REF = DB_REF.child("notifications")
/// Ссылка на таблицу всех личных сообщений
let MESSAGES_REF = DB_REF.child("messages")
/// Ссылка на таблицу сообщений для конкретного пользователя
let USER_MESSAGES_REF = DB_REF.child("user-messages")
/// Ссылка на таблицу постов помеченных хэштегом
let HASHTAG_POST_REF = DB_REF.child("hashtag-post")

// MARK: - Перечисления для таблицы Notifications

///Тип уведомления отправляемого на сервер
enum NotificationType: Int, Printable {
    ///Уведомление о лайке поста
    case Like
    ///Уведомление о новом комментарии для поста
    case Comment
    ///Уведомление о новом подписчике
    case Follow
    ///Упоминание пользователя в комменатрии
    case CommentMention
    ///Упоминание пользователя в посте
    case PostMention
    
    init(index: Int) {
        switch index {
        case 0: self = .Like
        case 1: self = .Comment
        case 2: self = .Follow
        case 3: self = .CommentMention
        case 4: self = .PostMention
        default: self = .Like
        }
    }
    
    var description: String {
        switch self {
        case .Like: return "понравился ваш пост "
        case .Comment: return "прокомментировал вашу публикацию "
        case .Follow: return "подписался на вас "
        case .CommentMention: return "упоминул(а) вас в комментарии"
        case .PostMention: return "отметил(а) вас в публикации"
        }
    }
}
