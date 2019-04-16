//
//  NotificationCell.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 12/03/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    // MARK: - Свойства
    
    var delegate: NotificationCellDelegate?
    
    ///Данные о уведомлении
    var notification: Notification? {
        didSet {
            guard let user = notification?.user,
                  let userName = user.username,
                  let notificationMessage = notification?.type.description,
                  let profileImageURL = user.profileImageURL else { return }
            
            profileImageView.loadImage(with: profileImageURL)
            configureNotificationLabelText(userName: userName, message: notificationMessage)
            configureNotificationType()
            
            if let post = notification?.post {
                postImageView.loadImage(with: post.imageURL)
            }
            
        }
    }
    
    ///Аватар пользователя
    let profileImageView: CustomImageView = {
        let image = CustomImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .lightGray
        image.layer.cornerRadius = 20
        return image
    }()
    
    ///Текст уведомления
    let notificationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    ///Кнопка подписаться или отписаться
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleTapFollowButton), for: .touchUpInside)
        
        return button
    }()
    
    ///Фотография лайкнутого или прокомментированного поста
    lazy var postImageView: CustomImageView = {
        let image = CustomImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .lightGray
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapPost))
        tap.numberOfTapsRequired = 1
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(tap)
        
        return image
    }()
    
    private var paddingRightConstraint: NSLayoutConstraint!
    
    // MARK: - Инициализаторы

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureViewComponents()
        paddingRightConstraint = notificationLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 0)
        
        selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Настройка внешнего вида окна
    
    /// Расставляем все необходимые UI компоненты на экране
    private func configureViewComponents(){
        
        addSubview(profileImageView)
        profileImageView.setPosition(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

    }
    
    /// Настраивает текст уведомления для отображения
    ///
    /// - Parameters:
    ///     - userName: Имя пользователя оставившего уведомление
    ///     - message: Текст уведомления
    private func configureNotificationLabelText(userName: String, message: String) {
        
        let attributedText = NSMutableAttributedString(string: "\(userName) ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: "\(message) ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)]))
        attributedText.append(NSAttributedString(string: getPostTimeInteval() ?? "Недавно", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        notificationLabel.attributedText = attributedText
    }
    
    ///Настраивает вид отображения ячейки в зависимости от типа уведомления
    private func configureNotificationType() {
        guard let notification = notification,
              let user = notification.user else {return}
        
        //notification.type = все кроме подписки нового пользователя
        if notification.type != .Follow {
            //Если ограничения для ячейки еще не созданы, то создаем их, иначе новые не создавать
            //Эта проверка нужна, так как мы создаем эти ограничения не из инициализатора, а после того как мы установим данные в свойство notification и этот метод будет вызывать большое количество раз так как все ячейки в collectionView переиспользуемые, рано или поздно будет конфликт ограничений, и их будет огромное количетсво
            if postImageView.constraints.count < 1 {
                addSubview(postImageView)
                postImageView.setPosition(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 40, height: 40)
                postImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            }
            followButton.isHidden = true
            postImageView.isHidden = false
        }
        else {
            if followButton.constraints.count < 1 {
                addSubview(followButton)
                followButton.setPosition(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 120, height: 30)
                followButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            }
            //Чтобы кнопка и фото не появлялись одновременно

            followButton.isHidden = false
            postImageView.isHidden = true
            
            user.checkIfUserIsFollowed { (result) in
                
                if result {
                    self.followButton.setTitle("Отписаться", for: .normal)
                    self.followButton.setTitleColor(.black, for: .normal)
                    self.followButton.layer.borderColor = UIColor.lightGray.cgColor
                    self.followButton.layer.borderWidth = 0.5
                    self.followButton.backgroundColor = .white
                }
                else {
                    self.followButton.setTitle("Подписаться", for: .normal)
                    self.followButton.setTitleColor(.white, for: .normal)
                    self.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
                    self.followButton.layer.borderWidth = 0
                }
            }
        }
        
        if notificationLabel.constraints.count < 1 {
            addSubview(notificationLabel)
            notificationLabel.setPosition(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
            notificationLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            paddingRightConstraint.isActive = true
        }
        
        //В итоге, вместо создания новых ограничений, мы просто будем менять значение константы у ограничения для отступа либо от кнопки либо от икноки фотографии для текста уведомления
        //В зависимости от того что нужно отобразить подсчитываем отсуп от правого края для текста уведомления
        if postImageView.isHidden {
            paddingRightConstraint.constant = -128
        }
        else{
            paddingRightConstraint.constant = -48
        }
    }
    
    ///Возвращает дату когда данный пост был опубликован в определенном формате
    private func getPostTimeInteval() -> String? {
        
        guard let notification = self.notification else {return nil}
        
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        
        dateFormatter.maximumUnitCount = 1
        dateFormatter.unitsStyle = .abbreviated
        
        let now = Date()
        let dateToDisplay = dateFormatter.string(from: notification.creationDate, to: now)
        
        return dateToDisplay
    }
    
    // MARK: - Обработка нажатия кнопок
    
    @objc func handleTapFollowButton() {
        delegate?.handleTapFollow(for: self)
    }
    
    @objc func handleTapPost() {
        delegate?.handleTapPost(for: self)
    }
    
}
