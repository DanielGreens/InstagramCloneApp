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
    
    ///Выбранная пользователем фотография
    let photoImageView: UIImageView = {
        let photo = UIImageView()
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
    lazy var sharePostButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.setTitle("Опубликовать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleTapShareButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        configureViewComponents()
        
        descriptionTextForPhoto.delegate = self
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
        view.addSubview(sharePostButton)
        sharePostButton.setPosition(top: photoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 24, paddingBottom: 0, paddingRight: 24, width: 0, height: 40)
    }
    
    // MARK: - Обработка нажатий
    
    @objc func handleTapShareButton() {
        
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
    
    // MARK: - Вспомогательные функции
    
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
    
    // MARK: - UITextViewDelegate
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard !textView.text.isEmpty else {
            sharePostButton.isEnabled = false
            sharePostButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        sharePostButton.isEnabled = true
        sharePostButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        
    }
}
