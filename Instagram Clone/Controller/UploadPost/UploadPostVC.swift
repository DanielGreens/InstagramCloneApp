//
//  UploadPostVC.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 13/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

//Публикация нового поста
class UploadPostVC: UIViewController, UITextViewDelegate {
    
    // MARK: - Свойства
    
    ///Варианты отображения кнопки
    enum UploadAction: Int {
        ///Загрузить пост
        case UploadPost
        ///Сохранить изменения
        case SaveChanges
        
        init(index: Int) {
            switch index {
            case 0:
                self = .UploadPost
            case 1:
                self = .SaveChanges
            default:
                self = .UploadPost
            }
        }
    }
    var uploadAction: UploadAction!
    
    ///Информация о редактируемом посте
    var post: Post?
    
    ///Выбранная пользователем фотография
    let photoImageView: CustomImageView = {
        let photo = CustomImageView()
        photo.contentMode = .scaleAspectFill
        photo.clipsToBounds = true
        photo.backgroundColor = .lightGray
        return photo
    }()
    
    ///Текст для нового поста
    let descriptionTextForPhoto: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.groupTableViewBackground
        textView.font = UIFont.systemFont(ofSize: 12)
        return textView
    }()
    
    ///Кнопка опубликовать
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleTapButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        configureViewComponents()
        descriptionTextForPhoto.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if uploadAction == .SaveChanges {
            guard let post = post else {return}
            navigationItem.title = "Редактирование поста"
            actionButton.setTitle("Сохранить изменения", for: .normal)
            photoImageView.loadImage(with: post.imageURL)
            descriptionTextForPhoto.text = post.description
        }
        else {
            actionButton.setTitle("Опубликовать", for: .normal)
        }
    }
    
    // MARK: - Настройка внешнего вида окна
    
    /// Расставляем все необходимые UI компоненты на экране
    private func configureViewComponents() {
        
        //Фотография выбранная пользователем
        view.addSubview(photoImageView)
        photoImageView.setPosition(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 102, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        
        //Описание для поста
        view.addSubview(descriptionTextForPhoto)
        descriptionTextForPhoto.setPosition(top: view.topAnchor, left: photoImageView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 102, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 100)
        
        //Кнопка опубликовать
        view.addSubview(actionButton)
        actionButton.setPosition(top: photoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 24, paddingBottom: 0, paddingRight: 24, width: 0, height: 40)
    }
    
    // MARK: - Обработка нажатий
    
    @objc func handleTapButton() {
        
        buttonSelector(uploadAction: uploadAction)
    }
    
    ///В зависимости от типа кнопки, вызывает необходимую функцию
    private func buttonSelector(uploadAction: UploadAction) {
        switch uploadAction {
        case .UploadPost:
            uploadPost()
        case .SaveChanges:
            saveEditChanges()
        }
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard !textView.text.isEmpty else {
            actionButton.isEnabled = false
            actionButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        actionButton.isEnabled = true
        actionButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        
    }
    
    // MARK: - Работа с БД
    
    ///Загружает созданный пост на сервер
    private func uploadPost() {
        
        guard let postDescription = descriptionTextForPhoto.text, let postImage = photoImageView.image, let currentID = Auth.auth().currentUser?.uid else {return}
        
        guard let uploadData = postImage.jpegData(compressionQuality: 0.5) else {return}
        
        //Дата создания поста
        let creationData = Int(NSDate().timeIntervalSince1970)
        
        //Создаем уникальный идентификатор
        let filename = NSUUID().uuidString
        
        STORAGE_POST_IMAGES_REF.child(filename).putData(uploadData, metadata: nil) { (metadata, error) in
            
            if let error = error {
                print("Ошибка загрузки фотографии поста - \(error.localizedDescription)")
                return
            }
            
            STORAGE_POST_IMAGES_REF.child(filename).downloadURL(completion: { (downloadURL, error) in
                //Путь к изображение загружаемого поста
                guard let postImageUrl = downloadURL?.absoluteString else {
                    print("Ошибка: Путь к фото пользователя равен nil - \(String(describing: error?.localizedDescription))")
                    return
                }
                
                //Сохраняемые данные
                let values = ["description" : postDescription,
                              "creationDate" : creationData,
                              "likes" : 0,
                              "postImageUrl" : postImageUrl,
                              "ownerID": currentID] as [String : Any]
                //Идентификатор поста (Создается в соответствии с датой создания - так написано в документации)
                let postID = POSTS_REF.childByAutoId()
                
                //Загружаем данные
                postID.updateChildValues(values, withCompletionBlock: { (error, ref) in
                    //Если в updateChildValues написать postID.key то не будет работать, поэтому извлекаем
                    guard let postIdKey = postID.key else {return}
                    
                    //Обновляем данные в таблице user-posts
                    //Добавляем к пользователю currentID идентифкатор нового созданного поста postID
                    USER_POSTS_REF.child(currentID).updateChildValues([postIdKey : 1])
                    
                    //Обновляем таблицу постов с хэштегами
                    self.uploadHashtag(with: postIdKey)
                    
                    //Загружаем уведомление об упоминании в описании поста
                    if postDescription.contains("@") {
                        self.uploadMentionsNotification(for: postIdKey, with: postDescription, notificationType: .PostMention)
                    }
                    
                    //Обновляем ленту новостей подписчиков и самого пользователя
                    self.updateUsersFeeds(with: postIdKey)
                    
                    //Возвращаемся на новостную ленту
                    self.dismiss(animated: true, completion: {
                        self.tabBarController?.selectedIndex = 0
                    })
                })
            })
        }
    }
    
    ///Сохраняет сделанные изменения для поста
    private func saveEditChanges() {
        
        guard let post = post,
              let description = descriptionTextForPhoto.text else {return}
        
        //Обновляем описание поста
        POSTS_REF.child(post.postID).child("description").setValue(description) { (error, ref) in
            self.navigationController?.popViewController(animated: true)
        }
        //Если описание поста содержит хэштег, то мы добавим его
        uploadHashtag(with: post.postID)
    }
    
    ///Обновляет ленту подписчиков добавленной публикацией текущего пользователя
    private func updateUsersFeeds(with postID: String) {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        
        let values = [postID : 1]
        
        //Обновляем ленту новостей для полписчиков текущего пользователя
        USER_FOLLOWERS_REF.child(currentUserID).observe(.childAdded) { (dataFromDB) in
            let followerID = dataFromDB.key
            USER_FEED_REF.child(followerID).updateChildValues(values)
        }
        
        //Обновляем ленту новостей текущего пользователя
        USER_FEED_REF.child(currentUserID).updateChildValues(values)
    }
    
    ///Если в описании поста есть хэштег, то он будет добавлен в БД
    /// - Parameters:
    ///     - postID: Идентификатор поста с хэштегом
    private func uploadHashtag(with postID: String){
        
        guard let description = descriptionTextForPhoto.text else {return}
        
        //Разеделяем описание поста на слова которые начинаются с символа #
        let words = description.components(separatedBy: .whitespacesAndNewlines)
        
        for var word in words {
            if word.hasPrefix("#"){
                word = word.trimmingCharacters(in: .punctuationCharacters)
                word = word.trimmingCharacters(in: .symbols)
                
                let hashtagValues = [postID : 1]
                
                HASHTAG_POST_REF.child(word.lowercased()).updateChildValues(hashtagValues)
            }
        }
    }
}
