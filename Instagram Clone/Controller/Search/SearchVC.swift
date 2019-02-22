//
//  SearchVC.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 13/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

///Идентификатор ячейки таблицы
private let reuseIdentifier = "SearchUserCell"

class SearchVC: UITableViewController {
    
    // MARK: - Свойства
    ///Все полученные из БД пользователи
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()

        //Регестрируем Ячейку на наш класс SearchUserCell
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        //Настриваем раззделители ячеек, чтобы разделение начиналось когда заканчивается аватар пользователя
        //64 слева, потому что размер аватарки 48, и плюс по 8 с двух краев для симметрии
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0)
        
        congigureNavController()
        
        fetchUsers()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchUserCell
        cell.user = users[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let user = users[indexPath.row]
        
        //Создаем страницу с пользователем на которого кликнули
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout())
        
        //Передаем данные о выбранном пользователе в UserProfileVC
        userProfileVC.user = user
        
        navigationController?.pushViewController(userProfileVC, animated: true)
    }
    
    // MARK: - Настройка внешнего вида окна
    
    ///Настраиваем панель навигации
    private func congigureNavController() {
        navigationItem.title = ""
    }
    
    
    // MARK: - Работа с Базой данных
    
    ///Загружает данные о пользователях из БД
    private func fetchUsers() {
        
        USER_REF.observe(.childAdded) { (dataFromDB) in
            //Этот блок вызывается для каждого пользователя
            
            guard let dictionary = dataFromDB.value as? Dictionary<String, AnyObject> else {return}
            //Уникальный идентификатор пользователя
            let uid = dataFromDB.key
            
            let user = User(uid: uid, dictionary: dictionary)
            
            self.users.append(user)
            self.tableView.reloadData()
        }
    }

}
