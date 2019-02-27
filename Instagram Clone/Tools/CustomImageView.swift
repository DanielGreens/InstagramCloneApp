//
//  CustomImageView.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 25/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit

///Коллекция закэшированных изображение [Ссылка на изображение : Изображение]
var imageCache = [String : UIImage]()

class CustomImageView : UIImageView {

    ///Хранит ссылку на последнее загружаемое изображение
    var lastImageUrlUsedToLoadImage: String?
    
    /// Загружаем картинку по адресу в БД
    /// - Parameters:
    ///     - urlString: Ссылка на необходимую картинку
    func loadImage(with urlString: String) {
        
        //Чтобы изображения не мигали во время загрузки, мы обнуляем его каждй раз в nil когда происходит загрузка изображения
        self.image = nil
        
        lastImageUrlUsedToLoadImage = urlString
        
        //Проверяем есть ли изображение в кэше
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        //Если изображения нету в кэше
        //Создаем ссылку на нужное изображение
        guard let url = URL(string: urlString) else {return}
        
        //Загружаем изображение по созданной ссылке
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            //Обработка ошибки
            if let error = error {
                print("Не получилось загрузить изображение - \(error.localizedDescription)")
            }
            
            //Этим блоком кода мы избегаем бага, в следствие которого у нас появлялись дупликаты изображения в постах пользователя
            //Фактически, здесь мы хотим убедиться, что мы используем ту ссылку для загрузки изображения, которая соответствует тому изображению поста которое мы хотим получить
            if self.lastImageUrlUsedToLoadImage != url.absoluteString {
                return
            }
            
            //Изображение
            guard let imageData = data else {return}
            let photoImage = UIImage(data: imageData)
            
            //Сохраняем изображение в кэш
            imageCache[url.absoluteString] = photoImage
            
            //Устанавливаем изображение в необходимое место
            DispatchQueue.main.async {
                self.image = photoImage
            }
        }.resume()
    }
}
