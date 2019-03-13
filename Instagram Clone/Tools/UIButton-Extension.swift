//
//  UIButton-Extension.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 13/03/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import Foundation
import Firebase

extension UIButton {
    
    ///Настраивает отображение кнопки Подписаться\Отписаться
    /// - Parameters:
    ///     - didFollow: Если true - делаем кнопку Подписаться, иначе Отписаться
    func configureFollowButton(didFollow: Bool) {
        if didFollow {
            self.setTitle("Подписаться", for: .normal)
            self.setTitleColor(.white, for: .normal)
            self.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            self.layer.borderWidth = 0
        }
        else {
            self.setTitle("Отписаться", for: .normal)
            self.setTitleColor(.black, for: .normal)
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.layer.borderWidth = 0.5
            self.backgroundColor = .white
        }
    }
}
