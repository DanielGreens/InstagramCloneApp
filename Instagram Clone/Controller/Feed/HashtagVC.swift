//
//  HashtagVC.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 18/03/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "HashtagCell"

class HashtagVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - Свойства
    
    ///Все посты в описании которых присутствует выбранный пользователем хэштег
    var posts = [Post]()
    ///Хэштег который просматривает пользователь
    var hashtag: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(HashtagCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white
        navigationItem.title = "#\(hashtag!)"
        
        fetchPost()
    }
    
    //Чтобы на контроллерах куда мы переходим не было текста у кнопки назад
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HashtagCell
        
        cell.post = posts[indexPath.row]
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout())
        feedVC.viewSinglePost = true
        feedVC.post = posts[indexPath.item]
        navigationController?.pushViewController(feedVC, animated: true)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    // MARK: - Работа с БД
    
    /// Загружает все посты с выбранным хештегом
    private func fetchPost() {
        
        guard let hashtag = self.hashtag else {return}
        
        HASHTAG_POST_REF.child(hashtag).observe(.childAdded) { (dataFromDB) in
            
            let postID = dataFromDB.key
            
            Database.fetchPost(with: postID, completion: { (post) in
                
                self.posts.append(post)
                self.collectionView.reloadData()
            })
        }
    }
    
}
