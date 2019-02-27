//
//  FeedVC.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 13/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class FeedVC: UICollectionViewController {

    // MARK: - Свойства
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView.backgroundColor = .white

        configureNavigationBar()
    }
    
    // MARK: - Настройка внешнего вида окна
    
    /// Настраивает кнопку LogOut
    private func configureNavigationBar() {

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "logout"), style: .plain, target: self, action: #selector(handleTapLogOut))
        
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
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
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
    
    @objc func handleTapSendMessage() {
        
    }
}
