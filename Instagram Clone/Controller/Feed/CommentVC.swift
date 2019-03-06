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
    
    ///Идентификатор комментируемого поста
    var postID: String?
    ///Все комментарии для текущего поста
    var comments = [Comment]()
    
    ///Контейнер для набора комментария
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        containerView.backgroundColor = .white
        
        containerView.addSubview(commentTextField)
        containerView.addSubview(postButton)
        commentTextField.setPosition(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: postButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        postButton.setPosition(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        postButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        containerView.addSubview(separatorView)
        separatorView.setPosition(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        return containerView
    }()
    
    ///Текстовое поля для написания комментария
    let commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите комментарий"
        textField.font = UIFont.systemFont(ofSize: 14)
        return textField
    }()
    
    ///Кнопка публикации комменатрия
    lazy var postButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "send2"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleTapPostButton), for: .touchUpInside)
        return button
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
        
        guard let postID = self.postID else {return}
        
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
    
    
    // MARK: - Обработка нажатия кнопок
    
    @objc func handleTapPostButton() {
        
        guard let commentText = commentTextField.text, let currentUserID = Auth.auth().currentUser?.uid, let postID = postID else {return}
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        let values = ["commentText": commentText,
                      "creationDate" : creationDate,
                      "userID" : currentUserID] as [String : Any]
        
        COMMENTS_REF.child(postID).childByAutoId().updateChildValues(values) { (error, ref) in
            self.commentTextField.text = nil
        }
    }
}
