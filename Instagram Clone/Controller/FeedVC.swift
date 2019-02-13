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

        configureLogOutButton()
    }
    
    // MARK: - Настройка внешнего вида окна
    
    /// Настраивает кнопку LogOut
    private func configureLogOutButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LogOut", style: .plain, target: self, action: #selector(handleTapLogOut))
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
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            
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
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
