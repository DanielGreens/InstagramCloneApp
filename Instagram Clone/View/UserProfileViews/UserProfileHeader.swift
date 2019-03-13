//
//  UserProfileHeader.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 13/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

class UserProfileHeader: UICollectionViewCell {
    
    // MARK: - Свойства
    
    var delegate: UserProfileHeaderDelegate?
    
    var user: User? {
        // didSet вызывается сразу после того как значение user инициализировано
        didSet {
            guard let user = user else {return}
            
            configureEditOrFollowButton()
            configureUserStats(userID: user.userID)
            nameLabel.text = user.name
            guard let profileImageURL = user.profileImageURL else {return}
            profileImageView.loadImage(with: profileImageURL)
        }
    }
    
    // MARK: - UI элементы
    
    ///Аватар пользователя
    let profileImageView: CustomImageView = {
        let image = CustomImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .lightGray
        return image
    }()
    
    ///Имя пользователя
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    ///Количество постов пользователя
    let postLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "5\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "публикации", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        label.attributedText = attributedText
        
        return label
    }()
    
    ///Количество подписчиков пользователя
    lazy var folowersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        //Добавляем нажатие на надпись
        let followerTap = UITapGestureRecognizer(target: self, action: #selector(handleTapFollowersLabel))
        followerTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followerTap)
        return label
    }()
    
    ///Количество подписок пользователя
    lazy var folowLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        //Добавляем нажатие на надпись
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleTapFollowLabel))
        followTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(followTap)
        return label
    }()
    
    ///Кнопка редактирования профиля
    lazy var editProfileOrFollowButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        //Если мы не сделаем кнопку как lazy, то данную строчку нужно перенести в метот init, иначе нажатие на кнопку не будет работать. Мне кажется это происходит потому, что в данный момент self еще не создан, а соответственно мы не можем привязаться к нужному методу. А так как lazy вызовется уже тогда когда self будет создан, то привязка произойдет адекватно.
        button.addTarget(self, action: #selector(handleTapEditProfileOrFollow), for: .touchUpInside)
        return button
    }()
    
    ///Кнопка отображения публикация в виде таблицы
    let gridButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "grid"), for: .normal)
        return button
    }()
    
    ///Кнопка отображения публикация в виде списка
    let listButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    ///Кнопка отображения закладок
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
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
        
        //Добавляем аватарку пользователя
        addSubview(profileImageView)
        profileImageView.setPosition(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.layer.cornerRadius = 40
        
        //Добавялем имя пользователя
        addSubview(nameLabel)
        nameLabel.setPosition(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 14, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        //Выравнивание имени по центру аватарки
        //nameLabel.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
        
        //Устанавливаем надписи
        let stackView = UIStackView(arrangedSubviews: [postLabel, folowersLabel, folowLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.setPosition(top: topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50)
        
        //Устанавливаем кнопку редактирования профиля
        addSubview(editProfileOrFollowButton)
        editProfileOrFollowButton.setPosition(top: postLabel.bottomAnchor, left: postLabel.leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 12, width: 0, height: 30)
        
        configureBottomToolBar()
    }
    
    ///Настраиваем панель кнопок для типа отображения публикаций
    private func configureBottomToolBar(){
        
        //Разделитель панели сверху
        let topDividerView = UIView()
        topDividerView.backgroundColor = .lightGray
        
        //Разделитель панели снизу
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = .lightGray
        
        //Сама панель
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDividerView)
        addSubview(bottomDividerView)
        
        stackView.setPosition(top: nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        topDividerView.setPosition(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        bottomDividerView.setPosition(top: stackView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    ///Настраиваем вариант отображения кнопки. Либо это кнопка редактирвоания профиля, либо это кнопка подписаться или отписаться от профиля
    private func configureEditOrFollowButton(){
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        guard let user = self.user else {return}
        
        if currentUserID == user.userID{
            editProfileOrFollowButton.setTitle("Редактировать профиль", for: .normal)
        }
        else{
            editProfileOrFollowButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            editProfileOrFollowButton.setTitleColor(.white, for: .normal)
            editProfileOrFollowButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            user.checkIfUserIsFollowed { (isFollowed) in
                if isFollowed{
                    self.editProfileOrFollowButton.setTitle("Отписаться", for: .normal)
                }
                else{
                    self.editProfileOrFollowButton.setTitle("Подписаться", for: .normal)
                }
            }
        }
    }
    
    ///Получаем информацию о кличестве постов, подписчиков и подписок пользователя
    /// - Parameters:
    ///     - userID: Идентификатор пользователя, для которого происходит поиск информации в БД
    private func configureUserStats(userID: String) {
        delegate?.setUserStats(for: self, with: userID)
    }
    
    // MARK: - Обработчики нажатий
    
    @objc func handleTapEditProfileOrFollow() {
        delegate?.handleTapEditProfileOrFollow(for: self)
    }
    
    @objc func handleTapFollowersLabel() {
        //Анимация нажатия
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.allowUserInteraction, .autoreverse], animations: {
            self.folowersLabel.alpha = 0.3
        }) { (_) in
            self.folowersLabel.alpha = 1
        }
        delegate?.handleTapFollowers(for: self)
    }

    @objc func handleTapFollowLabel() {
        //Анимация нажатия
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.allowUserInteraction, .autoreverse], animations: {
            self.folowLabel.alpha = 0.3
        }) { (_) in
            self.folowLabel.alpha = 1
        }
        delegate?.handleTapFollow(for: self)
    }
    
}
