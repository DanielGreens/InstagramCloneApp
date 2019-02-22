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


// MARK: - Ссылки на необходимые таблицы в БД

/// Ссылка на данные о Пользователях
let USER_REF = DB_REF.child("users")

/// Ссылка на таблицу подписок для пользователя
let USER_FOLLOWING_REF = DB_REF.child("user-following")
/// Ссылка на таблицу подписчиков пользователя
let USER_FOLLOWERS_REF = DB_REF.child("user-followers")
