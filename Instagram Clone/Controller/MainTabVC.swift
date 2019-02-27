//
//  MainTabVC.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 13/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

class MainTabVC: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        
        configureViewController()
        
        checkIsUserLogIn()
    }
    
    //Создаем анимацию появления ViewController для вкладки SelectImageVC
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        let index = viewControllers?.index(of: viewController)
        
        if index == 2 {
            let selectImageVC = SelectImageVC(collectionViewLayout: UICollectionViewFlowLayout())
            let navController = UINavigationController(rootViewController: selectImageVC)
            navController.navigationBar.tintColor = .black
            
            present(navController, animated: true, completion: nil)
            
            return false
        }
        return true
    }
    
    // MARK: - Настройка внешнего вида окна
    
    /// Настраиваем все страницы Таб бара на необходимые контроллеры представления
    func configureViewController() {
        
        //Домашняя страница
        let feedVC = constructNavController(unselectedImage: UIImage(named: "home_unselected")!, selectedImage: UIImage(named: "home_selected")!, rootViewController: FeedVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //Страница поиска
        let searchVC = constructNavController(unselectedImage: UIImage(named: "search_unselected")!, selectedImage: UIImage(named: "search_selected")!, rootViewController: SearchVC())
        
        //Страница добавления фотографии
        let selectImageVC = constructNavController(unselectedImage: UIImage(named: "plus_unselected")!, selectedImage: UIImage(named: "plus_unselected")!)
        
        //Страница уведомлений
        let notificationVC = constructNavController(unselectedImage: UIImage(named: "like_unselected")!, selectedImage: UIImage(named: "like_selected")!, rootViewController: NotificationVC())
        
        //Страница личного профиля
        let userProfileVC = constructNavController(unselectedImage: UIImage(named: "profile_unselected")!, selectedImage: UIImage(named: "profile_selected")!, rootViewController: UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout()))
        
        //Добавляем созданные Контроллеры на ТАб бар
        viewControllers = [feedVC, searchVC, selectImageVC, notificationVC, userProfileVC]
        tabBar.tintColor = .black
    }
    
    /// Настраивает контроллер навигации
    ///
    /// - Parameters:
    ///     - unselectedImage: Изображение которое представляет текущую страницу
    ///     - selectedImage: Изображение которое необходимо когда данная страница активна
    ///     - rootViewController: Родительский экран
    /// - Returns:
    ///     Созданный контроллер навигации
    private func constructNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        
        //Создаем контроллер навигации с необходимыми настройками
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.tintColor = .black
        
        return navController
    }
    
    // MARK: - Вспомогательные функции
    
    /// Проверяет авторизирован ли пользователь в БД
    private func checkIsUserLogIn() {
        
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                //Помещяем окно авторизации в корень контроллера навигации
                let navigationController = UINavigationController(rootViewController: LoginVC())
                self.present(navigationController, animated: true, completion: nil)
            }
        }
    }

}
