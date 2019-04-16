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
    
    ///Это свойство обычно используется для присоединения вспомогательного вида к предоставленной системой клавиатуре, которая представлена для объектов UITextField и UITextView.
    override var inputAccessoryView: UIView {
        get {
            return containerView
        }
    }
    
    ///Этот метод возвращает false по умолчанию. Подклассы должны переопределить этот метод и вернуть true, чтобы иметь возможность стать первым респондентом.
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - Жизненный цикл Контроллера
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        collectionView.backgroundColor = .white
        
        //Перетаскивание по вертикали разрешаем, даже если содержимое меньше границ представления прокрутки.
        //Тоесть если есть всего две ячейки, мы все равно можем подвигать экран вверх и вниз
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        
        navigationItem.title = "Комментарии"
        
        fetchComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        
        //Добавляем наблюдателя за изменением рамки клавиатуры
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.tabBar.isHidden = false
        
        //Удаляем наблюдателя за изменением рамки клавиатуры и наблюдателя за изменением текста в UITextView
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(InputTextView.self, name: UITextView.textDidChangeNotification, object: nil)
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
                //Вызываем метод прокрутки таблицы только после того как обновляем содержимое таблицы, для корректности
                self.scrollCollectionViewToBottom()
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
    
    // MARK: - Обработка событий
    
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
    
    ///Меняется положение клавиатуры
    @objc func keyboardWillShow(notification: NSNotification) {
        //        ссылка на сайт - http://derpturkey.com/maintain-uitableview-scroll-position-with-keyboard-expansion/
        //        Open Keyboard
        //        Begin: { Origin: {X: 0, Y: 568}, Size: {W: 320, H: 253}}
        //        End:   { Origin: {X: 0, Y: 315}, Size: {W: 320, H: 253}}
        
        //        Close Keyboard
        //        Begin: { Origin: {X: 0, Y: 315}, Size: {W: 320, H: 253}}
        //        End:   { Origin: {X: 0, Y: 568}, Size: {W: 320, H: 253}}
        
        //Обрабатываем появление клавиатуры, только если комментарии есть, так как этот метод вызывается в первый раз при первоначальном открытии окна, когда еще ничего не загружено
        if self.comments.count > 0 {
            
            //Начальное положение координат клавиатуры
            let beginFrame = ((notification as NSNotification).userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            //Конечное положение координат клавиатуры
            let endFrame = ((notification as NSNotification).userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            //Если delta > 0, то клавиатура закрывается, если delta < 0, то клавиатура открывается
            let delta = (endFrame.origin.y - beginFrame.origin.y)
            
            //Если клавиатура появляется
            if delta < 0 {
                
                //Эта проверка нужна для закоментированного метода
                if !isScrolledToBottom(originYOfKeyboard: endFrame.origin.y) {
                    
                    //Разница между координатами клавиатуры и высотой содержимого для collectionView
                    //ЭТО ДЛЯ ЗАКОМЕНИТРОВАННОГО МЕТОДА В БЛОКЕ АНИМАЦИИ
//                    let height = contentOffsetAfterKeyboardAppears(originYOfKeyboard: endFrame.origin.y)
                    
                    //Получаем длительность анимации появления клавиатуры
                    let keyboardAnimationDuration = ((notification as NSNotification).userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double)
                    
                    let animationCurveRawNSN = ((notification as NSNotification).userInfo![UIResponder.keyboardAnimationCurveUserInfoKey]) as? NSNumber
                    let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
                    let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
                    
                    UIView.animate(withDuration: keyboardAnimationDuration, delay: 0, options: animationCurve, animations: {
                        //Закоментированные строки, поднимает содержимое collectionView так же как и в iMessage. Тоесть содержимое идет не вместе с клавиатурой, а немного запаздывая за ней. (Видно в медленной анимации) Для этого решения закомментрировать contentOffset и раскоментировать layoutIfNeeded()
                        self.view.layoutIfNeeded()
                        
                        //При этом решении содержимое collectionView поднимается одновременно с клавиатурой, как в WhatsApp, но в конце движения есть небольшой эффект bounse
                        //По сути эта строка показывает collectionView какая часть его содержимого должна быть на самом верху. Чтобы посмотреть раскоментировать в completion
                        //self.collectionView.contentOffset = CGPoint(x: 0, y: height)
                    }, completion: { (completed:Bool) in
                        self.scrollCollectionViewToBottom()
                        //                    let separatorView2 = UIView()
                        //                    separatorView2.backgroundColor = .blue
                        //                    self.collectionView.addSubview(separatorView2)
                        //                    self.collectionView.bringSubviewToFront(separatorView2)
                        //                    separatorView2.frame = CGRect(x: 0, y: height, width: self.view.frame.width, height: 2)
                    })
                }
                //Когда убираем клавиатуру все возвращается на свои места автоматически
            }
        }
    }
    
    // MARK: - Вспомогательные функции
    
    ///Метод который возвращает разницу между высотой содержимого collectionView прокручено в самый низ и начальной точкой по оси У, у frame клавиатуры
    /// - Parameters:
    ///     - originYOfKeyboard: Высота клавиатуры
    /// - Returns:
    ///     Разница между высотами
    private func contentOffsetAfterKeyboardAppears(originYOfKeyboard: CGFloat) -> CGFloat {
        
        if self.comments.count > 0 {
            
            //Высота всего содержимого collectionView
            let height = self.view.bounds.size.height - (self.collectionView.bounds.size.height - self.collectionView.contentSize.height - (self.navigationController?.navigationBar.frame.height)! - UIApplication.shared.statusBarFrame.size.height)
            
            //Показывает границу контента colletionView
//            let separatorView = UIView()
//            separatorView.backgroundColor = .red
//            self.view.addSubview(separatorView)
//            self.view.bringSubviewToFront(separatorView)
//            separatorView.frame = CGRect(x: 0, y: height, width: self.view.frame.width, height: 1)
            
            //Показывает верхнюю границу клавиатуры
//            let separatorView2 = UIView()
//            separatorView2.backgroundColor = .blue
//            self.view.addSubview(separatorView2)
//            self.view.bringSubviewToFront(separatorView2)
//            separatorView2.frame = CGRect(x: 0, y: originYOfKeyboard, width: self.view.frame.width, height: 2)
            
            return abs(height - originYOfKeyboard)
        }
        
        return 0
    }
    
    ///Проверяет высоту содержимого для collectionView
    /// - Parameters:
    ///     - originYOfKeyboard: Высота клавиатуры
    /// - Returns:
    ///     Если высота контента в collectionView ниже чем верхняя точка клавиатуры, то возвращает true, иначе false
    private func isScrolledToBottom(originYOfKeyboard: CGFloat) -> Bool {
        
        if self.comments.count > 0 {
            
            //Высота всего содержимого collectionView
            let height = self.view.bounds.size.height - (self.collectionView.bounds.size.height - self.collectionView.contentSize.height - (self.navigationController?.navigationBar.frame.height)! - UIApplication.shared.statusBarFrame.size.height)
            
            return height < originYOfKeyboard
        }
        
        return false
    }
    
    ///Пролистывает коллекцию в самый низ
    private func scrollCollectionViewToBottom() {
        let section = 0
        let lastItemIndex = self.comments.count - 1
        if lastItemIndex > 0 {
            let indexPath:NSIndexPath = NSIndexPath.init(item: lastItemIndex, section: section)
            self.collectionView.scrollToItem(at: indexPath as IndexPath, at: .bottom, animated: true)
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
