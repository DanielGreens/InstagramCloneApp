//
//  MessagesCell.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 14/03/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

class MessageCell: UITableViewCell {
    
    // MARK: - Свойства
    
    ///Информация о сообщении
    var message: Message? {
        didSet {
            guard let messageText = message?.messageText else {return}
            detailTextLabel!.text = messageText
            
            if let time = message?.creationDate {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "ru_RU")
                dateFormatter.dateFormat = "HH:mm"  //Формат 24 часа, если hh - то формат 12 часов
                timeLabel.text = dateFormatter.string(from: time)
            }
            
            configureUserData()
        }
    }
    
    ///Аватар пользователя
    let profileImageView: CustomImageView = {
        let image = CustomImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .lightGray
        image.layer.cornerRadius = 25
        return image
    }()
    
    ///Время последнего сеанса чата
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .darkGray
        
        return label
    }()
    
    
    // MARK: - Инициализаторы
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        configureViewComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Настройка внешнего вида окна
    
    /// Расставляем все необходимые UI компоненты на экране
    private func configureViewComponents(){
        
        addSubview(profileImageView)
        profileImageView.setPosition(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        addSubview(timeLabel)
        timeLabel.setPosition(top: topAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 20, width: 0, height: 0)
        
        detailTextLabel?.setPosition(top: textLabel?.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: timeLabel.leftAnchor, paddingTop: 3, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        textLabel?.text = " "
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 70, y: textLabel!.frame.origin.y - 5, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.numberOfLines = 2
        textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        detailTextLabel?.textColor = .lightGray
    }
    
    private func configureUserData() {
        
        guard let chatPartnerID = message?.getChatPartnerData() else {return}
        
        Database.fetchUser(with: chatPartnerID) { (user) in
            self.profileImageView.loadImage(with: user.profileImageURL)
            self.textLabel?.text = user.username
        }
        
    }
    
    
    // MARK: - Обработка нажатия кнопок
}
