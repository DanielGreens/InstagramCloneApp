//
//  UserProfileVC.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 13/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"
private let headerIdenifier = "UserProfileHeader"

class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - Свойства
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = .white

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdenifier)

//        fetchUserData()
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        //Определяем заголовок в котором хранится информация о пользователе
        let userProfileHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdenifier, for: indexPath) as! UserProfileHeader
        
        //Получаем уникальный идентификатор текущего пользователя
        guard let currentUserID = Auth.auth().currentUser?.uid else {return userProfileHeader}
        
        //Получаем данные из таблицы users, пользователья с currentUserID
        Database.database().reference().child("users").child(currentUserID).observeSingleEvent(of: .value) { (dataFromDB) in
            
            //Получаем словарь данных о пользователя из БД
            guard let userDictionary = dataFromDB.value as? Dictionary<String, AnyObject> else {return}
            //Создаем пользователя на основе данных из словаря
            self.user = User(uid: currentUserID, dictionary: userDictionary)
            
            self.navigationItem.title = self.user?.username
            userProfileHeader.user = self.user
            
        }
        
        //Устанавливаем данные пользователя
//        if let user = self.user {
//            userProfileHeader.user = user
//        }
//        else {
//            print("Пользователь не существуюет в БД")
//        }
        
        return userProfileHeader
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)

    
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    //Создаем размер области где будет информация о пользователе
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
 
    // MARK: - API
    
    /// Получает данные текущего пользователя
    private func fetchUserData() {
        
        //Получаем уникальный идентификатор текущего пользователя
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        
        //Получаем данные из таблицы users, пользователья с currentUserID
        Database.database().reference().child("users").child(currentUserID).observeSingleEvent(of: .value) { (dataFromDB) in
            
            //Получаем словарь данных о пользователя из БД
            guard let userDictionary = dataFromDB.value as? Dictionary<String, AnyObject> else {return}
            //Создаем пользователя на основе данных из словаря
            self.user = User(uid: currentUserID, dictionary: userDictionary)
            
            self.navigationItem.title = self.user?.username
        }
    }
    

}
