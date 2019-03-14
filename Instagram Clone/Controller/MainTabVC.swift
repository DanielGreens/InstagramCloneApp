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
    
    // MARK: - Свойства
    
    let dot = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        
        configureViewController()
        
        configureNotificationDot()
        
        observeNotifications()
        
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
        else if index == 3 {
            dot.isHidden = true
            return true
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
    
    ///Устанавливает точку если есть новые уведомления
    private func configureNotificationDot() {
        
        if UIDevice().userInterfaceIdiom == .phone {
            let tabBarHeight = tabBar.frame.height

            //Для айфона X, XS и XS Max
            if UIScreen.main.nativeBounds.height > 2400 {
                //5 - общее количество страницек в таб баре, 3 - индекс страницы на которую мы хотим установить точку
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - tabBarHeight, width: 6, height: 6)
            }
            //Для остальных
            else {
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - 16, width: 6, height: 6)
            }
            
            dot.center.x = (view.frame.width / 5 * 3 + (view.frame.width / 5) / 2)
            dot.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1)
            dot.layer.cornerRadius = 3
            
            view.addSubview(dot)
            dot.isHidden = true
        }
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
    
    ///Проверяет есть ли не просмотренные уведомления
    private func observeNotifications() {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        //Получаем список уведомлений для текущего пользователя
        NOTIFICATONS_REF.child(currentUserID).observeSingleEvent(of: .value) { (dataFromDB) in
            
            guard let allObject = dataFromDB.children.allObjects as? [DataSnapshot] else {return}
            
            allObject.forEach({ (data) in
                
                let notificationID = data.key
                //Проверяем у каждого уведомления поле checked
                NOTIFICATONS_REF.child(currentUserID).child(notificationID).child("checked").observeSingleEvent(of: .value, with: { (data) in
                    
                    guard let checked = data.value as? Int else {return}
                    
                    //Не просмотренные уведомления
                    if checked == 0 {
                        self.dot.isHidden = false
                    }
                        //Просмотренные уведомления
                    else {
                        self.dot.isHidden = true
                    }
                })
            })
        }
    }

}
