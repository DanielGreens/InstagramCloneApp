//
//  HashtagCell.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 18/03/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit

class HashtagCell: UICollectionViewCell {
    
    // MARK: - Свойства
    
    var post: Post? {
        
        didSet{
            guard let imageUrl = post?.imageURL else {return}
            postImageView.loadImage(with: imageUrl)
        }
    }
    
    ///Фото публикации пользователя
    let postImageView: CustomImageView = {
        let image = CustomImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .lightGray
        return image
    }()
    
    
    // MARK: - Инициализаторы
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(postImageView)
        postImageView.setPosition(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
