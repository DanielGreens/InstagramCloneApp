//
//  CommentVC.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 01/03/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "CommentCell"

class CommentVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Свойства
    
    ///Информация комментируемого поста
    var post: Post?
    ///Все комментарии для текущего поста
    var comments = [Comment]()
    
    ///Контейнер для набора комментария
    lazy var containerView: InputAccesoryView = {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let containerView = InputAccesoryView(frame: frame)
        containerView.backgroundColor = UIColor.groupTableViewBackground
        containerView.autoresizingMask = .flexibleHeight
        containerView.delegate = self
        
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView.backgroundColor = .white
        //Перетаскивание по вертикали разрешаем, даже если содержимое меньше границ представления прокрутки.
        //Тоесть если есть всего две ячейки, мы все равно можем подвигать экран вверх и вниз
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
//        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
//        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        navigationItem.title = "Комментарии"
        
        fetchComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
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
    
    // MARK: - UICollectionView DataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        
        cell.comment = comments[indexPath.item]
        
        handleTapHashtag(for: cell)
        handleTapUserMention(for: cell)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //Делаем автонастраиваемую ячейку по высоте
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        //Фиктивная ячейка для подсчета необходимого размера
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: view.frame.width, height: 1000)
        //Этот метод возвращает значение размера для представления, которое оптимально удовлетворяет текущим ограничениям представления и максимально приближено к значению в параметре targetSize.
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        //Выбираем максимальную получившуюся высоту и относительного нее будет настраиваться ячейка
        let height = max(56, estimatedSize.height)
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    
    // MARK: - Работа с Базой Данных
    
    ///Загружает все комментарии для данного поста
    private func fetchComments() {
        
        guard let postID = self.post?.postID else {return}
        
        COMMENTS_REF.child(postID).observe(.childAdded) { (dataFromDB) in
            
            let commentID = dataFromDB.key
            
            guard let dictionary = dataFromDB.value as? Dictionary<String, AnyObject> else {return}
            
            guard let userID = dictionary["userID"] as? String else {return}
            
            Database.fetchUser(with: userID, completion: { (user) in
                let comment = Comment(commentID: commentID, user: user, dictionary: dictionary)
                self.comments.append(comment)
                self.collectionView.reloadData()
            })
        }
    }
    
    ///Отправляет уведомление о новом комментарии для поста на сервер
    private func uploadCommentNotificationToServer() {
        
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let postID = self.post?.postID,
              let userID = self.post?.user?.userID else { return }
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        //Значение уведомления
        let values = ["checked" : 0,
                      "creationDate" : creationDate,
                      "userID" : currentUserID,
                      "type": NotificationType.Comment.rawValue,
                      "postID" : postID] as Dictionary<String, Any>
        
        //Загружаем информацию на сервер, только если пользователь комментирует не свой пост
        if currentUserID != userID {
            NOTIFICATONS_REF.child(userID).childByAutoId().updateChildValues(values)
        }
    }
    
    // MARK: - Обработка нажатия кнопок
    
    ///Нажат хэштег в комментариях
    func handleTapHashtag(for cell: CommentCell) {
        
        cell.commentLabel.handleHashtagTap { (hashtag) in
            let hashtagVC = HashtagVC(collectionViewLayout: UICollectionViewFlowLayout())
            hashtagVC.hashtag = hashtag.lowercased()
            self.navigationController?.pushViewController(hashtagVC, animated: true)
        }
    }
    
    ///Нажато имя пользователя упомянутое в комменатрии (например @ironman)
    func handleTapUserMention(for cell: CommentCell) {
        
        cell.commentLabel.handleMentionTap { (mention) in
            self.getMentionedUser(with: mention)
        }
    }
}

// MARK: - InputAccsesoryViewDelegate

extension CommentVC : InputAccsesoryViewDelegate {
    
    //Публикация комментария
    func handleSendButton(forText text: String) {
        
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let postID = post?.postID else {return}
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let values = ["commentText": text,
                      "creationDate" : creationDate,
                      "userID" : currentUserID] as [String : Any]
        
        COMMENTS_REF.child(postID).childByAutoId().updateChildValues(values) { (error, ref) in
            self.uploadCommentNotificationToServer()
            //Если текст комментария содержит @, то создаем уведомление об упоминании пользователя
            if text.contains("@") {
                self.uploadMentionsNotification(for: postID, with: text, notificationType: .CommentMention)
            }
        }
        
        self.containerView.clearCommentTextView()
    }
}