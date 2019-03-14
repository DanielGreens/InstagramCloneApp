//
//  ChatCell.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 14/03/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

class ChatCell: UICollectionViewCell {
    
    // MARK: - Свойства
    
    var message: Message? {
        didSet {
            
            guard let messageText = message?.messageText,
                let chatPartnerID = message?.getChatPartnerData() else {return}
            
            messageView.text = messageText
            Database.fetchUser(with: chatPartnerID) { (user) in
                guard let profileImageUrl = user.profileImageURL else {return}
                self.profileImageView.loadImage(with: profileImageUrl)
            }
        }
    }
    
    ///Динамическая ширина ячейки
    var bubbleWidthAnhor: NSLayoutConstraint?
    ///Если сообшение от текущего пользователя, то оно будет справа
    var bubbleRightAnchor: NSLayoutConstraint?
    ///Если сообшение не от текущего пользователя, то оно будет слева
    var bubbleLeftAnchor: NSLayoutConstraint?
    
    ///Контейнер для сообщения
    let bubbleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 0, green: 137, blue: 249)
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    ///Текст сообщения
    let messageView: UITextView = {
        let textView = UITextView()
        textView.text = "Some test text for messages from me"
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.isEditable = false
        //Если вы хотите использовать автоматическую компоновку для ДИНАМИЧЕСКОГО расчета размера и позиции вашего представления, вы должны установить для этого свойства значение false, а затем предоставить не двусмысленный, не конфликтующий набор ограничений для представления.
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    ///Аватар пользователя
    let profileImageView: CustomImageView = {
        let image = CustomImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .lightGray
        image.layer.cornerRadius = 16
        return image
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
        
        addSubview(bubbleView)
        addSubview(messageView)
        addSubview(profileImageView)
        
        profileImageView.setPosition(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: -4, paddingRight: 0, width: 32, height: 32)
        
        //Размещаем сообщения справа
        bubbleRightAnchor = bubbleView.rightAnchor.constraint(equalTo: rightAnchor, constant: -8)
        bubbleRightAnchor?.isActive = true
        
        //Размещаем сообщения справа
        bubbleLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
        bubbleLeftAnchor?.isActive = false
        
        //Ширина и верх сообщения
        bubbleView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        bubbleWidthAnhor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
        bubbleWidthAnhor?.isActive = true
        bubbleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
        messageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
        messageView.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        messageView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
        messageView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    // MARK: - Обработка нажатия кнопок
    
    
    
}
