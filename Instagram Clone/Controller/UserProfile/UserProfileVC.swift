//
//  UserProfileVC.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 13/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

///Идентификатор ячейки коллекции
private let reuseIdentifier = "UserPostCell"
///Идентификатор заголовка колекции для пользовательской информации
private let headerIdentifier = "UserProfileHeader"

///Страница информации о пользователе
class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - Свойства
    
    ///Данные о пользователе
    var user: User?
    ///Данные о постах пользователя
    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = .white

        //Регестрируем ячейки на соответствующие классы и присваиваем им уникальные идентификаторы
        self.collectionView!.register(UserPostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)

        if user == nil {
            fetchUserData()
        }
        
        fetchUserPosts()
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        //Определяем заголовок в котором хранится информация о пользователе
        let userProfileHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader
        
        userProfileHeader.delegate = self
        
        //Устанавливаем данные пользователя
        userProfileHeader.user = user
        navigationItem.title = user?.username
        
        return userProfileHeader
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserPostCell

        cell.post = posts[indexPath.item]
    
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        feedVC.viewSinglePost = true
        feedVC.post = posts[indexPath.row]
        
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    //Создаем размер области где будет информация о пользователе
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
 
    // MARK: - Работа с Базой данных
    
    /// Получает данные текущего пользователя из БД
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
            self.collectionView.reloadData()
        }
    }
    
    ///Загружаем посты пользователя
    private func fetchUserPosts() {
        
        var userID: String!
        
        if let user = self.user {
            userID = user.userID
        }
        else {
            userID = Auth.auth().currentUser?.uid
        }
        
        //Создаем постоянного наблюдателя за обновлением данных. Если в БД добавится новый пост, данные обгновятся здесь автоматически
        USER_POSTS_REF.child(userID).observe(.childAdded) { (dataFromDB) in
            
            let postID = dataFromDB.key
            
            Database.fetchPost(with: postID, completion: { (post) in
                
                self.posts.append(post)
                
                //Сортируем посты по дате создания (Старые посты в конец, новые вперед)
                self.posts.sort(by: { (post1, post2) -> Bool in
                    return post1.creationDate > post2.creationDate
                })
                
                self.collectionView.reloadData()
            })
        }
    }
}

// MARK: - Реализация протокола UserProfileHeaderDelegate

extension UserProfileVC : UserProfileHeaderDelegate {
    
    func handleTapEditProfileOrFollow(for header: UserProfileHeader) {
        
        guard let user = header.user else {return}
        
        if header.editProfileOrFollowButton.titleLabel?.text == "Редактировать профиль" {
            
        }
        else{
            if header.editProfileOrFollowButton.titleLabel?.text == "Подписаться" {
                header.editProfileOrFollowButton.setTitle("Отписаться", for: .normal)
                user.follow()
            }
            else{
                header.editProfileOrFollowButton.setTitle("Подписаться", for: .normal)
                user.unfollow()
            }
        }
    }
    
    func setUserStats(for header: UserProfileHeader, with userID: String) {
        
        //Количество подписчиков
        var numberOfFollowers: Int!
        //Количество подписок пользователя
        var numberOFFollowing: Int!
        
        //Получаем количество подписчиков для пользователя userID
        //В данном случае мы используем метод observe, а не observeSingleEvent, потому что мы хотим чтобы при подписке на пользователя, данные о их количестве в folowersLabel и folowLabel обновились тут же. Метод observe наблюдает за изменениями "постоянно" в режиме реального времени, это то что мы хотим для этих данных. А метод observeSingleEvent единовременно получает данные.
        //Для примера, если мы нажмем на кнопку подписаться с методом observe то количество подписчиков изменится тут же, а если сделать то же самое с методом observeSingleEvent, то количество подписчиков не изменится.
        USER_FOLLOWERS_REF.child(userID).observe(.value) { (dataFromDB) in
            
            if let data = dataFromDB.value as? Dictionary<String, AnyObject> {
                numberOfFollowers = data.count
            }
            else {
                numberOfFollowers = 0
            }
            
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowers!)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "подписчики", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
            header.folowersLabel.attributedText = attributedText
        }
        //Получаем количество подписок для пользователя userID
        USER_FOLLOWING_REF.child(userID).observe(.value) { (dataFromDB) in
            
            if let data = dataFromDB.value as? Dictionary<String, AnyObject> {
                numberOFFollowing = data.count
            }
            else {
                numberOFFollowing = 0
            }
            
            let attributedText = NSMutableAttributedString(string: "\(numberOFFollowing!)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "подписки", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
            header.folowLabel.attributedText = attributedText
        }
    }

    func handleTapFollowers(for header: UserProfileHeader) {
        let followersVC = FollowVC()
        followersVC.navigationItem.title = "Подписчики"
        followersVC.viewFollowers = true
        //Передаем ID пользователя не текущего а того чей профиль мы просматриваем, так как попасть на количество подписок и подписчиков мы можем как со страницы текущего пользователя, так и со старницы поиска, нажав на интересующего человек, и уже с его профиля посмотреть его подписки. Поэтому передаем ID того пользователя чью страницу мы просматриваем
        followersVC.userID = user?.userID
        navigationController?.pushViewController(followersVC, animated: true)
    }
    
    func handleTapFollow(for header: UserProfileHeader) {
        let followVC = FollowVC()
        followVC.navigationItem.title = "Подписки"
        followVC.viewFollow = true
        followVC.userID = user?.userID
        navigationController?.pushViewController(followVC, animated: true)
    }
}
