//
//  UserProfileHeader.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 13/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit

class UserProfileHeader: UICollectionViewCell {
    
    var user: User? {
        // didSet вызывается сразу после того как значение user инициализировано
        didSet {
            nameLabel.text = user?.name
            
            guard let profileImageURL = user?.profileImageURL else {return}
            profileImageView.loadImage(with: profileImageURL)
        }
    }
    
    // MARK: - UI элементы
    
    ///Аватар пользователя
    let profileImageView: UIImageView = {
        let image = UIImageView()
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
    let folowersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "6\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "подписчики", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        label.attributedText = attributedText
        
        return label
    }()
    
    ///Количество подписок пользователя
    let folowLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let attributedText = NSMutableAttributedString(string: "7\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "подписки", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        label.attributedText = attributedText
        
        return label
    }()
    
    ///Кнопка редактирования профиля
    let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Редактировать профиль", for: .normal)
        button.layer.cornerRadius = 5
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
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
        addSubview(editProfileButton)
        editProfileButton.setPosition(top: postLabel.bottomAnchor, left: postLabel.leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 8, paddingBottom: 0, paddingRight: 12, width: 0, height: 30)
        
        configureBottomToolBar()
    }
    
    ///Настраиваем панель кнопок типа отображения публикаций
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
}
