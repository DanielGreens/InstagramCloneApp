//
//  UIImageView-Extension.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 15/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit

///Коллекция закэшированных изображение [Ссылка на изображение : Изображение]
var imageCache = [String : UIImage]()

extension UIImageView {
    
    
    /// Загружаем картинку по адресу в БД
    /// - Parameters:
    ///     - urlString: Ссылка на необходимую картинку
    func loadImage(with urlString: String) {
        
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
