//
//  FeedVC.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 13/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase
import ActiveLabel

private let reuseIdentifier = "FeedCell"

class FeedVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - Свойства
    
    ///Загруженные публикации
    var posts = [Post]()
    ///Хотим ли мы посмотреть информацию только о данной публикации
    var viewSinglePost = false
    ///Информация о выбранном посте
    var post: Post?
    ///Идентификато последнего загруженного поста
    var lastLoadPostID: String?
    
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
    }
    
    //Чтобы на контроллерах куда мы переходим не было текста у кнопки назад
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Настройка внешнего вида окна
    
    /// Настраивает кнопку LogOut
    private func configureNavigationBar() {

        //Если просматривается только один пост то скрываем кнопки LogOut и Личных сообщений
        if !viewSinglePost {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "logout"), style: .plain, target: self, action: #selector(handleTapLogOut))
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "send2"), style: .plain, target: self, action: #selector(handleTapSendMessage))
        }
        
        //Лого Интсаграмма в центре
        let imageView = UIImageView(image: UIImage(named: "Instagram_logo_black"))
        imageView.contentMode = .scaleAspectFill
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.frame = titleView.bounds
        titleView.addSubview(imageView)
        self.navigationItem.titleView = titleView
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
        
        handleTapHashtag(for: cell)
        handleTapUserMention(for: cell)
        handleTapUserNameInPostDescription(for: cell)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //Если в ленте у пользователя меньше 5 постов, то загружать новые не стоит
        if posts.count > 4 {
            //Когда видим предпоследний пост, загружаем новую пачку постов
            if indexPath.item == posts.count - 1 {
                fetchPosts()
            }
        }
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
    
    ///Нажата кнопка личные сообщения
    @objc func handleTapSendMessage() {
        
        let messagesVC = MessagesVC()
        navigationController?.pushViewController(messagesVC, animated: true)
    }
    
    ///Обновляет содержимое коллекции
    @objc func handleRefresh() {
        posts.removeAll()
        lastLoadPostID = nil
        fetchPosts()
        collectionView.reloadData()
    }
    
    ///Нажат хэштег
    func handleTapHashtag(for cell: FeedCell){
        
        cell.descriptionLabel.handleHashtagTap { (hashtag) in
            
            let hashtagVC = HashtagVC(collectionViewLayout: UICollectionViewFlowLayout())
            hashtagVC.hashtag = hashtag.lowercased()
            self.navigationController?.pushViewController(hashtagVC, animated: true)
        }
    }
    
    ///Нажато имя пользователя упомянутое в посте (например @ironman)
    func handleTapUserMention(for cell: FeedCell) {
        
        cell.descriptionLabel.handleMentionTap { (mention) in
            self.getMentionedUser(with: mention)
        }
    }
    
    ///Нажато имя пользователя в описании поста
    func handleTapUserNameInPostDescription (for cell: FeedCell) {
        
        guard let user = cell.post?.user,
              let username = user.username else {return}
        
        let customType = ActiveType.custom(pattern: "^\(username)\\b")
        
        cell.descriptionLabel.handleCustomTap(for: customType) { (username) in
            
            let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
            userProfileVC.user = user
            self.navigationController?.pushViewController(userProfileVC, animated: true)
        }
    }
    
    // MARK: - Работа с Базой Данных
    
    ///Загружает публикации в ленту
    private func fetchPosts() {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else{return}
        
        //Первоначальная загрузка первых 5 постов
        if lastLoadPostID == nil {
            USER_FEED_REF.child(currentUserID).queryLimited(toLast: 5).observeSingleEvent(of: .value) { (dataFromDB) in
                //Останаливаем контрол обновления коллекции
                self.collectionView.refreshControl?.endRefreshing()
                //Получаем идентификатор последнего загруженного поста и идентификаторы всех полученных постов
                guard let first = dataFromDB.children.allObjects.first as? DataSnapshot,
                    let allObjects = dataFromDB.children.allObjects as? [DataSnapshot] else {return}
                allObjects.forEach({ (data) in
                    let postID = data.key
                    self.fetchPost(with: postID)
                })
                self.lastLoadPostID = first.key
            }
        }
        //Иначе подгружаем следующие 6 постов начиная с lastLoadPostID
        else {
            //Сначала сортируем записи по времени по идентификаторам queryOrderedByKey, и получаем 6 записей начиная с lastLoadPostID
            USER_FEED_REF.child(currentUserID).queryOrderedByKey().queryEnding(atValue: self.lastLoadPostID).queryLimited(toLast: 6).observeSingleEvent(of: .value) { (dataFromDB) in
                
                //Получаем идентификатор последнего загруженного поста и идентификаторы всех полученных постов
                guard let first = dataFromDB.children.allObjects.first as? DataSnapshot,
                    let allObjects = dataFromDB.children.allObjects as? [DataSnapshot] else {return}
                
                allObjects.forEach({ (data) in
                    //Исключаем из загрузки последний загруженный пост и первый загруженный пост из новой пачки, так как они одинаковые (Тот пост на котором закончили последнюю загрузку, будет первым загруженным постом из новой загрузки)
                    if data.key != self.lastLoadPostID {
                        self.fetchPost(with: data.key)
                    }
                })
                
                self.lastLoadPostID = first.key
            }
        }
    }
    
    /// Загружает данные о публикации
    ///
    /// - Parameters:
    ///     - postID: Идентификатор загружаемого поста
    private func fetchPost(with postID: String) {
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
        guard let post = cell.post else {return}
        let commentVC = CommentVC(collectionViewLayout: UICollectionViewFlowLayout())
        commentVC.post = post
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
