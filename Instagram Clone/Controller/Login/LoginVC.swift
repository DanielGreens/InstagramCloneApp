//
//  LoginVC.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 10/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController {
    
    // MARK: - UI элементы
    
    let logoContainerView: UIView = {
        let view = UIView()
        let logoImage = UIImageView(image: UIImage(named: "Instagram_logo_white"))
        logoImage.contentMode = .scaleAspectFill
        view.addSubview(logoImage)
        logoImage.setPosition(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImage.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 175/255, alpha: 1)
        
        return view
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
//        textField.text = "tonystark@mail.ru"
        
        textField.addTarget(self, action: #selector(dataValidation), for: .editingChanged)
        return textField
    }()
    
    /// Пароль пользователя
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.isSecureTextEntry = true
        textField.autocapitalizationType = .none
//        textField.text = "123456"
        
        textField.addTarget(self, action: #selector(dataValidation), for: .editingChanged)
        return textField
    }()
    
    /// Кнопка авторизации
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        
        button.addTarget(self, action: #selector(handleTapLogIn), for: .touchUpInside)
        return button
    }()
    
    /// Кнопка регистрации
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?   ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        button.addTarget(self, action: #selector(handleTapSignUp), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //backgroundColor
        view.backgroundColor = .white
        
        //Скрываем навигационную панель
        navigationController?.navigationBar.isHidden = true
        
        configureViewComponents()
    }
    
    // MARK: - Настройка внешнего вида окна
    
    /// Расставляем все необходимые UI компоненты на экране
    private func configureViewComponents(){
        
        //Устанавливаем логотип
        view.addSubview(logoContainerView)
        logoContainerView.setPosition(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        
        //Устанавливаем текстовые поля и кнопку
        let stackView = UIStackView(arrangedSubviews: [emailTextField,passwordTextField,loginButton])
        
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.setPosition(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 140)
        
        //Устнавливаем кнопку регистрации
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.setPosition(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
    }
    
    // MARK: - Обработка нажатия кнопок
    
    /// Нажата кнопка авторизации
    @objc func handleTapLogIn() {
        
        guard let email = emailTextField.text, let password = passwordTextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            if let error = error {
                print("Ошибка авторизации - \(error.localizedDescription)")
                return
            }
            
            //В AppDelegate мы прописали что нашим стартовым экраном будет MainTabVC. Если при проверке авторизирован ли пользователь, окажется что он не авторизирован, то в стек контроллеров будет добавлен текущий контроллер LoginVC. А здесь в данный момент мы знаем что новая авторизация прошла успешно, мы просто достаем ранее созданный MainTabVC
            guard let mainTabVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabVC else {return}
            
            mainTabVC.configureViewController()
            
            //Уничтожаем LoginvVC
            self.dismiss(animated: true, completion: nil)
            
        }
    }
    
    /// Нажата кнопка зарегестрироваться
    @objc func handleTapSignUp() {
        let signUpVC = SignUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    // MARK: - Вспомогательные методы
    
    /// Проверка корректности введенных данных
    @objc func dataValidation() {
        
        //Проверяем что поля логин и пароль не пустые
        guard emailTextField.hasText, passwordTextField.hasText else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        
        loginButton.isEnabled = true
        loginButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }

}
