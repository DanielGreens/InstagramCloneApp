//
//  MessagesVC.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 14/03/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "MessagesCell"

class MessagesVC: UITableViewController {
    
    // MARK: - Свойства
    
    ///Диалоги пользователя
    var dialogs = [Message]()
    ///Словарь последних сообщений в каждом диалоге
    var lastDialogSessionMessages = [String : Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(MessageCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorColor = .clear
        
        configureNavigationBar()
        fetchChatSession()
    }
    
    //Чтобы на ChatVC  у кнопки назад не было текста, а была только иконка
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    // MARK: - TableViewDataSource
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dialogs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MessageCell
        
        cell.message = dialogs[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Получаем данные о сообщении
        let message = dialogs[indexPath.row]
        //Определяем собеседника
        let chatPartnerID = message.getChatPartnerData()
        Database.fetchUser(with: chatPartnerID) { (user) in
            //Открываем чат с выбранным пользователем
            self.showChatVC(with: user)
        }
    }
    
    // MARK: - Настройка внешнего вида окна
    
    ///Настраивает панель навигации
    private func configureNavigationBar() {
        
        navigationItem.title = "Сообщения"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleTapAddNewDialog))
        
    }
    
    // MARK: - Работа с БД
    
    ///Загружает все начатые диалоги пользователя
    private func fetchChatSession() {
        
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        
        self.dialogs.removeAll()
        self.lastDialogSessionMessages.removeAll()
        self.tableView.reloadData()
        
        USER_MESSAGES_REF.child(currentUserID).observe(.childAdded) { (dataFromDB) in
            
            let chatPartnerUserID = dataFromDB.key
            
            ///Получаем последние сообщение из сессии путем уточнения запроса queryLimited(toLast: 1) - возвращает последнюю запись
            USER_MESSAGES_REF.child(currentUserID).child(chatPartnerUserID).queryLimited(toLast: 1).observe(.childAdded, with: { (data) in
                
                let messageID = data.key
                Database.loadMessage(with: messageID, completion: { (message) in
                    
                    //С помощью словаря избегаем дублирования диалоговых сессий при появлении нового сообщения
                    //Обновится лишь последнее сообщение в диалоге
                    self.lastDialogSessionMessages[message.getChatPartnerData()] = message
                    self.dialogs = Array(self.lastDialogSessionMessages.values)
                    self.tableView.reloadData()
                })
            })
        }
    }
    
    // MARK: - Обработчики нажатий
    
    ///Добавляет новый диалог с пользователем
    @objc private func handleTapAddNewDialog() {
        
        let newMessageVC = NewMessageVC()
        //Устанавливаем, что родителем newMessageVC будет этот контроллер
        newMessageVC.parentVC = self
        let navController = UINavigationController(rootViewController: newMessageVC)
        self.present(navController, animated: true, completion: nil)
    }
    
    // MARK: - Вспомогательные функции
    
    /// Открывает чат с выбранным пользователем
    ///
    /// - Parameters:
    ///     - user: Пользователь с которым хотим начать чат
    public func showChatVC(with user: User) {
        let chatVC = ChatVC(collectionViewLayout: UICollectionViewFlowLayout())
        chatVC.user = user
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
