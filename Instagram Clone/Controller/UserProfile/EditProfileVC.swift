//
//  EditProfileVC.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 22/03/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

class EditProfileVC: UIViewController {
    
    // MARK: - Свойства
    
    ///Данные о пользователе
    var user: User?
    ///Изменил ли пользователь фотографию
    var isImageChange = false
    ///Родительский экран
    var userProfileVC: UserProfileVC?
    
    ///Аватар пользователя
    let profileImageView: CustomImageView = {
        let image = CustomImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .lightGray
        image.layer.cornerRadius = 40
        return image
    }()
    
    ///Изменить фото пользователя
    lazy var changePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Изменить фото профиля", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleTapChangePhotoButton), for: .touchUpInside)
        return button
    }()
    
    ///Разделитель
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    ///Никнейм пользователя
    let userNameTextField: UITextField = {
        let txtField = UITextField()
        txtField.textAlignment = .left
        txtField.borderStyle = .none
        return txtField
    }()
    
    ///Имя пользователя
    let nameTextField: UITextField = {
        let txtField = UITextField()
        txtField.textAlignment = .left
        txtField.borderStyle = .none
        return txtField
    }()
    
    ///Надпись Никнейм пользователя
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Никнейм"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    ///Надпись Имя пользователя
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Имя пользователя"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    ///Разделитель
    let userNameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    ///Разделитель
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        configureNavigationBar()
        configureViewComponents()
        setUserData()
        
        nameTextField.delegate = self
        userNameTextField.delegate = self
    }
    
    
    // MARK: - Настройка внешнего вида экрана
    
    ///Настраивает внешний вид Навигационной строки
    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleTapCancelButton))
        navigationItem.leftBarButtonItem?.tintColor = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleTapDoneButton))
        
        navigationItem.title = "Изменить профиль"
    }
    
    ///Настраивает отображение элементов на экране
    private func configureViewComponents() {
        //Получаем высоту NavigationBar + высота statusBar динамически, так как их высота на iphoneX и iphone 8 отличается
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        let frame = CGRect(x: 0, y: topBarHeight, width: view.frame.width, height: 150)
        let containerView = UIView(frame: frame)
        containerView.backgroundColor = UIColor.groupTableViewBackground
        view.addSubview(containerView)
        
        //Аватар пользователя
        containerView.addSubview(profileImageView)
        profileImageView.setPosition(top: containerView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        profileImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        //Кнопка изменить фото
        containerView.addSubview(changePhotoButton)
        changePhotoButton.setPosition(top: profileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        changePhotoButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        
        //Разделитель
        containerView.addSubview(separatorView)
        separatorView.setPosition(top: nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        //Надпись Имя пользователя
        view.addSubview(nameLabel)
        nameLabel.setPosition(top: containerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        //Имя пользователя
        view.addSubview(nameTextField)
        nameTextField.setPosition(top: containerView.bottomAnchor, left: nameLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: (view.frame.width / 2), height: 0)
        
        //Надпись Никнейм пользователя
        view.addSubview(userNameLabel)
        userNameLabel.setPosition(top: nameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        //Никнейм пользователя
        view.addSubview(userNameTextField)
        userNameTextField.setPosition(top: nameLabel.bottomAnchor, left: userNameLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 20, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: (view.frame.width / 2), height: 0)
        
        view.addSubview(nameSeparatorView)
        nameSeparatorView.setPosition(top: nil, left: nameLabel.rightAnchor, bottom: nameTextField.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0.5)
        
        view.addSubview(userNameSeparatorView)
        userNameSeparatorView.setPosition(top: nil, left: nameLabel.rightAnchor, bottom: userNameTextField.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 0.5)

    }
    
    ///Устанавливаем необходимые пользовательские данные
    private func setUserData() {
        
        guard let user = user else {return}
        profileImageView.loadImage(with: user.profileImageURL)
        nameTextField.text = user.name
        userNameTextField.text = user.username
    }
    
    // MARK: - Обработка нажатия кнопок
    
    ///Нажата кнопка Отмена
    @objc private func handleTapCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    ///Нажата кнопка Готово
    @objc private func handleTapDoneButton() {
        view.endEditing(true)
        
        updateUserData()
    }
    
    ///Нажата кнопка Изменить фото профиля
    @objc private func handleTapChangePhotoButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - Вспомогательные функции
    
    /// Проверяет изменились ли данные в Никнейме пользователя
    /// - Returns:
    ///     Возвращает строку если данные изменились, а если нет nil
    private func checkUserNameUpdated() -> String? {
        
        guard let user = user else { return nil }
        
        //Удаляем пробелы из строки
        let trimmedString = userNameTextField.text?.components(separatedBy: .whitespaces).joined()
        
        //Если никнейм не равен предыдущему и он не равен пустой строке, то возвращаем обновленную строку
        guard user.username != trimmedString?.lowercased(),
            trimmedString != "" else { return nil }
        
        return trimmedString?.lowercased()
        
    }
    
    /// Проверяет изменились ли данные в Имени пользователя
    /// - Returns:
    ///     Возвращает строку если данные изменились, а если нет nil
    private func checkNameUpdated() -> String? {
        
        guard let user = user else { return nil }
        
        guard user.name.lowercased() != nameTextField.text?.lowercased(),
            nameTextField.text != "" else { return nil }
        
        return nameTextField.text
    }
    
    
    // MARK: - Работа с базой данных
    
    ///Обновляет пользовательские данные в БД
    private func updateUserData() {
        
        //Если изменилась фотография пользователя
        if isImageChange == true {
            updateUserProfilePhoto()
        }
            //Если фото не изменилось смотрим изменились ли имя пользователя и никнейм
        else {
            updateUserNameAndNickName()
        }
    }
    
    ///Обновляет фотографию пользователя в БД
    private func updateUserProfilePhoto() {
        
        guard let currentUserID = Auth.auth().currentUser?.uid,
              let user = user else {return}
        
        //Удаляем старую фотографию
        Storage.storage().reference(forURL: user.profileImageURL).delete(completion: nil)
        
        let fileName = NSUUID().uuidString
        
        guard let updateProfileImage = profileImageView.image,
              let imageData = updateProfileImage.jpegData(compressionQuality: 0.5)  else {return}
        
        //Путь для сохранения фото пользователя с уникальным именем для изображения
        let storageRef = STORAGE_PROFILE_IMAGES_REF.child(fileName)
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Ошибка загрузке новой фотографии на сервер - \(error.localizedDescription)")
            }
            
            //После загрузки изображения на сервер, мы получаем путь к этому файлу
            storageRef.downloadURL(completion: { (downloadURL, error) in
                guard let updatedProfileImageUrl = downloadURL?.absoluteString else {
                    print("Ошибка: Путь к фото пользователя не создан")
                    return
                }
                
                USER_REF.child(currentUserID).child("profileImageUrl").setValue(updatedProfileImageUrl, withCompletionBlock: { (error, ref) in
                    
                    self.updateUserNameAndNickName()
                })
            })
        }
    }
    
    ///Обновляет имя пользователя и его никнейм
    private func updateUserNameAndNickName() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        
        var values = Dictionary<String, Any>()
        
        if let name = checkNameUpdated() {
            values["name"] = name
        }
        
        if let userName = checkUserNameUpdated() {
            values["username"] = userName
        }
        
        if values.count > 0 {
            USER_REF.child(currentUserID).updateChildValues(values) { (error, ref) in
                
                guard let userProfileVC = self.userProfileVC else {return}
                userProfileVC.fetchUserData()
                
                self.dismiss(animated: true, completion: nil)
            }
        }
        else if isImageChange {
            guard let userProfileVC = self.userProfileVC else {return}
            userProfileVC.fetchUserData()
            
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension EditProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - UINavigationControllerDelegate
    
    
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //Получаем выбранную фотографию
        if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImageView.image = selectedImage
            self.isImageChange = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}

extension EditProfileVC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
//        if textField == nameTextField {
//            if let _ = checkNameUpdated(){
//                navigationItem.rightBarButtonItem?.isEnabled = true
//            }
//        }
//
//
//        if textField == userNameTextField {
//            if let _ = checkUserNameUpdated(){
//                navigationItem.rightBarButtonItem?.isEnabled = true
//            }
//        }
    }
}
