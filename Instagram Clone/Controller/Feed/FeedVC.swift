//
//  FeedVC.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 13/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "FeedCell"

class FeedVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - Свойства
    
    ///Загруженные публикации
    var posts = [Post]()
    ///Хотим ли мы посмотреть информацию только о данной публикации
    var viewSinglePost = false
    ///Информация о выбранном посте
    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        
        //Настраиваем контроль обновления ленты
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        configureNavigationBar()
        
        //Если пользователь просматривает информацию только об одной публикации, то нам не зачем загружать информацию о всех постах
        if !viewSinglePost {
            fetchPosts()
        }
        
//        updateUserFeeds()
    }
    
    // MARK: - Настройка внешнего вида окна
    
    /// Настраивает кнопку LogOut
    private func configureNavigationBar() {

        if !viewSinglePost {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "logout"), style: .plain, target: self, action: #selector(handleTapLogOut))
        }
        
        //Лого Интсаграмма в центре
        let imageView = UIImageView(image: UIImage(named: "Instagram_logo_black"))
        imageView.contentMode = .scaleAspectFill
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.frame = titleView.bounds
        titleView.addSubview(imageView)
        self.navigationItem.titleView = titleView
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "send2"), style: .plain, target: self, action: #selector(handleTapSendMessage))
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //Если пользователь хочет просмотерть информацию только об одном посте, то взвращаем 1 ячейку, если он листает всю ленту то возвращаем количество равное количеству постов
        return viewSinglePost ? 1 : posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        
        cell.delegate = self
        
        if viewSinglePost {
            if let post = self.post {
                cell.post = post
            }
        }
        else {
            cell.post = posts[indexPath.item]
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        //Так как мы хотим чтобы картинка в ячейке была квадратной, то к ширине экрана мы добавляем высоту верхней части поста (16 = 8+8 отсутпы от аватара пользователя сверху и снизу и 40 - размет аватара пользователя, 50 - размер панели для кнопок, 50 - для описания фотографии и прочего
        let height = width + 16 + 40 + 50 + 60
        
        return CGSize(width: width, height: height)
    }

    
    // MARK: - Обработка нажатия кнопок
    
    /// Нажата кнопка LogOut
    @objc func handleTapLogOut() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //Выйти из профиля
        alertController.addAction(UIAlertAction(title: "Выйти", style: .destructive, handler: { (_) in
            
            do{
                try Auth.auth().signOut()
                //Помещяем окно авторизации в корень контроллера навигации
                let navigationController = UINavigationController(rootViewController: LoginVC())
                self.present(navigationController, animated: true, completion: nil)
            }
            //Если возникла ошибка
            catch{
                print("Не удалось выйти из профиля - \(error.localizedDescription)")
            }
        }))
        
        //Отменить выход из профиля
        alertController.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    ///Нажата кнопка отправить сообщение
    @objc func handleTapSendMessage() {
        
    }
    
    ///Обновляет содержимое коллекции
    @objc func handleRefresh() {
        posts.removeAll()
        fetchPosts()
        collectionView.reloadData()
    }
    
    // MARK: - Работа с Базой Данных
    
    ///Загружает публикации в ленту
    private func fetchPosts() {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else{return}
        
        USER_FEED_REF.child(currentUserID).observe(.childAdded) { (dataFromDB) in
            
            let postID = dataFromDB.key
            
            Database.fetchPost(with: postID, completion: { (post) in
                
                self.posts.append(post)
                
                //Сортируем посты по дате создания (Старые посты в конец, новые вперед)
                self.posts.sort(by: { (post1, post2) -> Bool in
                    return post1.creationDate > post2.creationDate
                })
                
                //Останаливаем контрол обновления коллекции
                self.collectionView.refreshControl?.endRefreshing()
                
                self.collectionView.reloadData()
            })
        }
    }
}

// MARK: - FeedCellDelegate Protocol

extension FeedVC : FeedCellDelegate {
    
    func handleTapUsername(for cell: FeedCell) {
        
        guard let post = cell.post else {return}
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        userProfileVC.user = post.user
        
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    func handleTapOption(for cell: FeedCell) {
        print("Детали")

    }
    
    func handleTapLike(for cell: FeedCell, isDoubleTap: Bool) {
        
        guard let post = cell.post else {return}
        guard let likes = post.likes else {return}
        
        //Если публикация уже лайкнута, то нужно снять лайк, и наоборот
        if post.didLike {
            //По двойному тапу по картинке мы можем только лайкнуть пост, а снять лайк двойным тапом нельзя
            if !isDoubleTap {
                post.setLikes(addLike: false) { (likes) in
                    cell.likesLabel.text = "Понравилось: \(likes)"
                }
                cell.likesLabel.text = "Понравилось: \(likes - 1)" //Вставляем здесь, чтобы анимация добавления лайка сработала сраз же, и не создавалась видимость зависания
                cell.likeButton.setImage(UIImage(named: "unlike"), for: .normal)
                cell.likeButton.tintColor = .black
            }
        }
        //Поставить лайк
        else {
            post.setLikes(addLike: true) { (likes) in
                cell.likesLabel.text = "Понравилось: \(likes)"
            }
            cell.likesLabel.text = "Понравилось: \(likes + 1)"
            cell.likeButton.setImage(UIImage(named: "like"), for: .normal)
            cell.likeButton.tintColor = .red
        }
    }
    
    func handleTapComment(for cell: FeedCell) {
        guard let postID = cell.post?.postID else {return}
        let commentVC = CommentVC(collectionViewLayout: UICollectionViewFlowLayout())
        commentVC.postID = postID
        navigationController?.pushViewController(commentVC, animated: true)
    }
    
    func handleConfigureLikeButton(for cell: FeedCell) {
        
        guard let post = cell.post else{return}
        guard let postID = post.postID else {return}
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        
        USER_LIKES_REF.child(currentUserID).observeSingleEvent(of: .value) { (dataFromDB) in
            //Если текущий пользователь лайкал этот пост, то сердчеко будет красным
            if dataFromDB.hasChild(postID) {
                post.didLike = true
                cell.likeButton.setImage(UIImage(named: "like"), for: .normal)
                cell.likeButton.tintColor = .red
            }
            else {
                post.didLike = false
                cell.likeButton.setImage(UIImage(named: "unlike"), for: .normal)
                cell.likeButton.tintColor = .black
            }
        }
    }
    
    func handleTapLikeLabel(for cell: FeedCell) {
        guard let postId = cell.post?.postID else {return}
        let followLikeVC = FollowLikeVC()
        followLikeVC.viewingMode = .Likes
        followLikeVC.postID = postId
        navigationController?.pushViewController(followLikeVC, animated: true)
    }
}
