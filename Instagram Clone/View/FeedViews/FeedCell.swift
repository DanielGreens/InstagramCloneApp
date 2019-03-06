//
//  FeedCell.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 27/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

class FeedCell: UICollectionViewCell {
    
    // MARK: - Свойства
    
    var delegate: FeedCellDelegate?
    
    ///Информация о публикации
    var post: Post? {
        
        didSet {
            guard let post = post else{return}
            //Информация о пользователе сделавшем публикацию
            guard let user = post.user else{return}
            
            profileImageView.loadImage(with: user.profileImageURL)
            usernameButton.setTitle(user.username, for: .normal)
            configurePostDescription(user: user)
            
            postImageView.loadImage(with: post.imageURL)
            likesLabel.text = "Понравилось: \(post.likes!)"
            configureLikeButton()
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
    
    ///Никнейм пользователя
    lazy var usernameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("UserName", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleTapUserName), for: .touchUpInside)
        return button
    }()
    
    ///Дополнительные действия с публикацией
    lazy var optionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("•••", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleTapOption), for: .touchUpInside)
        return button
    }()
    
    ///Фотография публикации
    lazy var postImageView: CustomImageView = {
        let image = CustomImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .lightGray
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapLikePost))
        doubleTap.numberOfTapsRequired = 2
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(doubleTap)
        return image
    }()
    
    ///Кнопка лайк
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "unlike"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleTapLike), for: .touchUpInside)
        return button
    }()
    
    ///Кнопка комментариев
    lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "comment"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleTapComment), for: .touchUpInside)
        return button
    }()
    
    ///Кнопка отправить сообщением
    let messageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "comment"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    ///Кнопка добавить публикацию в закладки
    let savePostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ribbon"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    ///Кому понравилось
    lazy var likesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(handleTapLikeLable))
        likeTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(likeTap)
        return label
    }()
    
    ///Текст описания поста
    let descriptionLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "Username", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: " Some text for description", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)]))
        label.attributedText = attributedText
        return label
    }()
    
    ///Время публикации поста
    let postTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .lightGray
        label.text = "2 ДНЯ НАЗАД"
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
        
        //Имя пользователя
        addSubview(usernameButton)
        usernameButton.setPosition(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        usernameButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        //Кнопка о деталях поста
        addSubview(optionButton)
        optionButton.setPosition(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        optionButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        
        //Фотография поста
        addSubview(postImageView)
        postImageView.setPosition(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        //Делаем фотографию поста квадратной. Высоту делаем равной ширине
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        
        configureSocialButtons()
        
        addSubview(likesLabel)
        likesLabel.setPosition(top: likeButton.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: -4, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        addSubview(descriptionLabel)
        descriptionLabel.setPosition(top: likesLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        addSubview(postTimeLabel)
        postTimeLabel.setPosition(top: descriptionLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    ///Настраиваем панель кнопок взаимодействия с публикацией
    private func configureSocialButtons(){
        
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, messageButton])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.setPosition(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 50)
        
        addSubview(savePostButton)
        savePostButton.setPosition(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 13, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 20, height: 24)
    }
    
    ///Настройка отображения описания публикации
    /// - Parameters:
    ///     - user: Информация о пользователе
    private func configurePostDescription(user: User) {
        
        guard let post = post else {return}
        
        let attributedText = NSMutableAttributedString(string: user.username, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: " \(post.description!)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)]))
        
        descriptionLabel.attributedText = attributedText
    }
    
    // MARK: - Обработка нажатия кнопок
    
    @objc func handleTapUserName() {
        delegate?.handleTapUsername(for: self)
    }
    
    @objc func handleTapOption() {
        delegate?.handleTapOption(for: self)
    }
    
    @objc func handleTapLike() {
        delegate?.handleTapLike(for: self, isDoubleTap: false)
    }
    
    @objc func handleTapComment() {
        delegate?.handleTapComment(for: self)
    }
    
    @objc func handleTapLikeLable() {
        delegate?.handleTapLikeLabel(for: self)
    }
    
    @objc func handleDoubleTapLikePost() {
        delegate?.handleTapLike(for: self, isDoubleTap: true)
    }
    
    func configureLikeButton() {
        delegate?.handleConfigureLikeButton(for: self)
    }
}
