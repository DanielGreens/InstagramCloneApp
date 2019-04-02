//
//  ChatVC.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 14/03/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "ChatCell"

class ChatVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Свойства
    
    ///Пользователь с которым ведется диалог
    var user: User?
    ///Сообщения текущего диалога
    var messages = [Message]()
    
    ///Контейнер для поля ввода над клавиатурой
    lazy var containerView: InputAccesoryView = {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let containerView = InputAccesoryView(frame: frame)
        containerView.backgroundColor = UIColor.groupTableViewBackground
        containerView.autoresizingMask = .flexibleHeight
        containerView.delegate = self
        
        return containerView
    }()
    
    ///Это свойство обычно используется для присоединения вспомогательного вида к предоставленной системой клавиатуре, которая представлена для объектов UITextField и UITextView.
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    ///Этот метод возвращает false по умолчанию. Подклассы должны переопределить этот метод и вернуть true, чтобы иметь возможность стать первым респондентом.
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - View Cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(ChatCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView.backgroundColor = .white
        
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
        configureNavigationBar()
        
        fetchMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - UICollectionView
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatCell
        
        cell.message = messages[indexPath.item]
        
        configureMessage(cell: cell, message: messages[indexPath.item])
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = calculateFrameForText(messages[indexPath.item].messageText).height + 20
        return CGSize(width: view.frame.width, height: height)
    }
    
    
    // MARK: - Настройка внешнего вида окна
    
    ///Настраивает панель навигации
    private func configureNavigationBar() {
        
        guard let url = user?.profileImageURL else { return }
        
        //Получаем изображение пользователя
        let profileImageView = CustomImageView()
        profileImageView.loadImage(with: url)
        //Создаем кнопку с этим изображением
        let icon = UIButton()
        icon.setImage(profileImageView.image, for: .normal)
        icon.addTarget(self, action: #selector(handleTapGoToUserProfile), for: .touchUpInside)
        icon.layer.cornerRadius = 17
        icon.clipsToBounds = true
        //Без этих ограничений, картинка будет автоматически растягиваться, так как начиная с ios 11 в UIBarButtonItem используется  autolayout заполняющий все место
        icon.widthAnchor.constraint(equalToConstant: 34.0).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 34.0).isActive = true
        //Добавляем созданную кнопку в UIBarButtonItem
        let iconButton = UIBarButtonItem(customView: icon)
        
        //Имя пользователя
        let userNameButton = UIBarButtonItem(title: user?.username, style: .plain, target: self, action: #selector(handleTapGoToUserProfile))

        navigationItem.leftItemsSupplementBackButton = true
        navigationItem.leftBarButtonItems = [iconButton, userNameButton]
        
        let infoButton = UIButton(type: .infoLight)
        infoButton.tintColor = .black
        infoButton.addTarget(self, action: #selector(handleTapInfo), for: .touchUpInside)
        
        let infoBarButton = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = infoBarButton
    }
    
    /// Считает необходимый размер для корректного отображения динамической ячейки
    ///
    /// - Parameters:
    ///     - text: Текст размер которого необходимо вычислить
    /// - Returns:
    ///     Возвращает необходимый размер ячейки
    private func calculateFrameForText(_ text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    private func configureMessage(cell: ChatCell, message: Message) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        let size = calculateFrameForText(message.messageText)
        cell.bubbleWidthAnhor?.constant = size.width + 32
        cell.frame.size.height = size.height + 20
        
        if message.fromUserID == currentUserID {
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
            cell.bubbleView.backgroundColor = UIColor.rgb(red: 0, green: 137, blue: 249)
            cell.messageView.textColor = .white
            cell.profileImageView.isHidden = true
        }
        else {
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
            cell.bubbleView.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
            cell.messageView.textColor = .black
            cell.profileImageView.isHidden = false
        }
    }
    
    // MARK: - Работа с БД
    
    ///Загружает сессию диалога с выбранным пользователем
    private func fetchMessages() {
        
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let chatPartnerUserID = self.user?.userID else {return}
        
        USER_MESSAGES_REF.child(currentUserID).child(chatPartnerUserID).observe(.childAdded) { (dataFromDB) in
            
            let messageID = dataFromDB.key
            
            Database.loadMessage(with: messageID, completion: { (message) in
                self.messages.append(message)
                self.collectionView.reloadData()
            })
        }
    }
    
    // MARK: - Обработчики нажатий
    
    ///Кнопка информации
    @objc private func handleTapInfo() {
        print("Info")
    }
    
    ///Открывает экран пользователя
    @objc private func handleTapGoToUserProfile() {
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = user
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
}

// MARK: - InputAccsesoryViewDelegate

extension ChatVC : InputAccsesoryViewDelegate {
    
    ///Отправляет сообщение на сервер
    func handleSendButton(forText text: String) {
        
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let user = self.user else {return}
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let messageValues = ["message" : text,
                             "fromUserID" : currentUserID,
                             "toUserID" : user.userID,
                             "creationDate" : creationDate] as Dictionary<String, Any>
        
        let messageRef = MESSAGES_REF.childByAutoId()
        
        guard let uniqueMessageID = messageRef.key else {return}
        
        //Добавляем данные в таблицу messages
        messageRef.updateChildValues(messageValues)
        
        //Добавляем данные в таблицу user-messages
        USER_MESSAGES_REF.child(currentUserID).child(user.userID).updateChildValues([uniqueMessageID : 1])
        
        USER_MESSAGES_REF.child(user.userID).child(currentUserID).updateChildValues([uniqueMessageID : 1])
        
        self.containerView.clearCommentTextView()
    }
}
