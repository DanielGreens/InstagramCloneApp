//
//  SignUpVC.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 10/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imageSelected = false
    
    // MARK: - UI элементы
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo")?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        button.addTarget(self, action: #selector(handleTapPlusPhoto), for: .touchUpInside)
        return button
    }()
    
    /// Почта пользователя
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        textField.addTarget(self, action: #selector(dataValidation), for: .editingChanged)
        return textField
    }()
    
    /// Пароль пользователя
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.isSecureTextEntry = true
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.autocapitalizationType = .none
        textField.addTarget(self, action: #selector(dataValidation), for: .editingChanged)
        return textField
    }()
    
    /// Имя пользователя
    let fullNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Full Name"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.addTarget(self, action: #selector(dataValidation), for: .editingChanged)
        return textField
    }()
    
    /// Ник пользователя
    let userNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "User Name"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.addTarget(self, action: #selector(dataValidation), for: .editingChanged)
        return textField
    }()
    
    /// Кнопка авторизации
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        
        button.addTarget(self, action: #selector(handleTapSignUp), for: .touchUpInside)
        return button
    }()
    
    /// Кнопка если уже зарегестрирован
    let alreadyHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?   ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleTapAlreadySignIn), for: .touchUpInside)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //backgroundColor
        view.backgroundColor = .white

        configureViewComponents()
    }
    
    // MARK: - Настройка внешнего вида окна
    
    /// Расставляем все необходимые UI компоненты на экране
    private func configureViewComponents(){
        
        //Устанавливаем кнопку добавления фотографии
        view.addSubview(plusPhotoButton)
        plusPhotoButton.setPosition(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        //Устанавливаем текстовые поля и кнопку
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, fullNameTextField, userNameTextField, signUpButton])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.setPosition(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 240)
        
        //Устнавливаем кнопку если уже зарегестрирован
        view.addSubview(alreadyHaveAccountButton)
        alreadyHaveAccountButton.setPosition(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    
    // MARK: - Обработка нажатий кнопок
    
    /// Нажата кнопка уже зарегестрирован
    @objc func handleTapAlreadySignIn() {
        navigationController?.popViewController(animated: true)
    }
    
    /// Нажата кнопка регистрации
    @objc func handleTapSignUp() {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let fullName = fullNameTextField.text else {return}
        guard let userName = userNameTextField.text else {return}
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            //Обработка ошибок
            if let error = error {
                print("Ошбика создания нового пользователя: \(error.localizedDescription)")
                return
            }
            
            //Фото пользователя
            guard let profileImage = self.plusPhotoButton.imageView?.image else {return}
            
            //Сжимаем фото пользователя для загрузки на сервер
            guard let uploadData = profileImage.jpegData(compressionQuality: 0.3) else {return}
            
            //Уникальный ID изображения
            let imageUniquePath = NSUUID().uuidString
            //Путь для сохранения фото пользователя с уникальным именем для изображения
            let storageRef = Storage.storage().reference().child("profile_images").child(imageUniquePath)
            
            //Загружаем фото на сервер в Storage
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                //Обработка ошибок
                if let error = error{
                    print("Ошибка загрузки изображения на сервер: \(error.localizedDescription)")
                }
                
                //После загрузки изображения на сервер, мы получаем путь к этому файлу
                storageRef.downloadURL(completion: { (downloadURL, error) in
                    guard let profileImageUrl = downloadURL?.absoluteString else {
                        print("Ошибка: Путь к фото пользователя равен nil")
                        return
                    }
                    
                    //Уникальный идентификатор данных пользователя
                    guard let uid = authResult?.user.uid else { return }
                    
                    //В profileImageUrl мы записываем путь к изображению которое мы загрузили ранее. Таким образом мы сослались на нужное нам изображение
                    let dictionaryValues = ["name": fullName,
                                            "username": userName,
                                            "profileImageUrl": profileImageUrl]
                    
                    let values = [uid: dictionaryValues]
                    
                    //Сохраняем данные пользователя в базу данных
                    Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (error, ref) in
                        
                        print("Everythings Okay")

//                        self.dismiss(animated: true, completion: nil)
                    })
                    
                })
                
            })
            
            //Если все хорошо
            print("Пользователь создан")
        }
    }
    
    /// Нажата кнопка добавить фото пользователя
    @objc func handleTapPlusPhoto() {
        
        //Настраиваем Image Picker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    // MARK: - Вспомогательные методы
    
    /// Проверка корректности введенных данных
    @objc func dataValidation() {
        guard emailTextField.hasText, passwordTextField.hasText, fullNameTextField.hasText, userNameTextField.hasText, imageSelected else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        
        signUpButton.isEnabled = true
        signUpButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
    

    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let profileImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            imageSelected = false
            return
        }
        
        imageSelected = true
        
        //Устанавливаем выбранное фото на кнопку
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 2
        plusPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        plusPhotoButton.contentMode = .scaleAspectFill
        
        self.dismiss(animated: true, completion: nil)
    }

}
