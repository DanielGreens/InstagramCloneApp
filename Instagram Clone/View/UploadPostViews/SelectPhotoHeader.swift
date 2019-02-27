//
//  SelectPhotoHeader.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 25/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit

class SelectPhotoHeader: UICollectionViewCell {
    
    // MARK: - Свойства
    
    ///Выбранное пользователем фото
    let photoImageView: UIImageView = {
        let photo = UIImageView()
        photo.contentMode = .scaleAspectFill
        photo.clipsToBounds = true
        photo.backgroundColor = .red
        return photo
    }()
    
    // MARK: - Инициалзиторы
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(photoImageView)
        photoImageView.setPosition(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
