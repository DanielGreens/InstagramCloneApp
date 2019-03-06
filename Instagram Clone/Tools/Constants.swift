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
/// Ссылка на таблитцу постов пользователей
let USER_POSTS_REF = DB_REF.child("user-posts")
/// Ссылка на таблицу - ленту новостей для пользователей
let USER_FEED_REF = DB_REF.child("user-feed")
/// Ссылка на таблицу - какой пользователь какие посты лайкнул
let USER_LIKES_REF = DB_REF.child("user-likes")
/// Ссылка на таблицу - кто лайкнул какой пост
let POST_LIKES_REF = DB_REF.child("post-likes")
/// Ссылка на таблицу комментариеы
let COMMENTS_REF = DB_REF.child("comments")
