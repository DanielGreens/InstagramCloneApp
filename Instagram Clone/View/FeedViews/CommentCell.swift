//
//  CommentCell.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 01/03/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import ActiveLabel

class CommentCell: UICollectionViewCell {
    
    // MARK: - Свойства
    
    ///Данные о комментарии
    var comment: Comment? {
        didSet {
            guard let profileImageURL = comment?.user?.profileImageURL,
                  let time = comment?.creationDate else {return}
            
            profileImageView.loadImage(with: profileImageURL)
            
//            let attributedText = NSMutableAttributedString(string: userName, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)])
//            attributedText.append(NSAttributedString(string: " \(commentText)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)]))
//            attributedText.append(NSAttributedString(string: " \(commentDate)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
//            commentLabel.attributedText = attributedText
            
            configureCommentLabel()
            timeLabel.text = time.getTimeInteval()
        }
    }

    ///Аватар пользователя
    private let profileImageView: CustomImageView = {
        let image = CustomImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .lightGray
        image.layer.cornerRadius = 20
        return image
    }()
    
    ///Комментарий пользователя
    let commentLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        return label
    }()
    
    ///Дата публикации комментария
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 0
        label.textColor = .lightGray
        return label
    }()
    
    // MARK: - Инициализаторы
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViewComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Настройка внешнего вида окна
    
    /// Расставляем все необходимые UI компоненты на экране
    private func configureViewComponents(){
        //Аватар пользователя
        addSubview(profileImageView)
        profileImageView.setPosition(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        
        //Комментарий
        addSubview(commentLabel)
        commentLabel.setPosition(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        addSubview(timeLabel)
        timeLabel.setPosition(top: commentLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 4, paddingRight: 8, width: 0, height: 0)
    }
    
    ///Настраивает отображение текста комментария
    private func configureCommentLabel() {
        
        guard let user = comment?.user,
              let userName = user.username,
              let commentText = comment?.commentText
//              let commentDate = getComentTimeInteval()
                else {return}
        
        //Настраиваем регулярное выражение на поиск имени в строке
        let customType = ActiveType.custom(pattern: "^\(userName)\\b")
        
        //Настраиваем регулярное выражение на поиск даты в строке
//        let customDateType = ActiveType.custom(pattern: "\\s\(commentDate)\\b")
        
        commentLabel.enabledTypes = [.mention, .hashtag, .url, customType/*, customDateType*/]
        
        //Настраиваем имя пользователя на жирный шрифт, так как обычный attributedText для ActiveLabel не работает
        //Настраиваем дату на светло-серый шрифт
        commentLabel.configureLinkAttribute = { (type, attributesDict, isSelected) in
            var attributes = attributesDict
            
            switch type {
            //Имя пользователя
            case customType:
                attributes[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 12)
            //Дата
//            case customDateType:
//                attributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: 12)
//                attributes[NSAttributedString.Key.foregroundColor] = UIColor.lightGray
            default: ()
            }
            return attributes
        }
        
        commentLabel.customize { (label) in
            label.text = "\(userName) \(commentText)" // Дата почему то отобразиться черным цветом \(commentDate)
            label.customColor[customType] = .black
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = .black
        }
    }
    
}
