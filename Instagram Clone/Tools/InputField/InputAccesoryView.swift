//
//  CommentInputAccesoryView.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 22/03/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit

///Класс представляет контенер для набора сообщения с кнопкой отправки
class InputAccesoryView: UIView {

    // MARK: - Свойства
    
    var delegate: InputAccsesoryViewDelegate?
    
    ///Текстовое поля для написания текста
    public let inputTextView: InputTextView = {
        let textView = InputTextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = false
        textView.textAlignment = .left
        textView.layer.cornerRadius = 10
        return textView
    }()
    
    ///Кнопка публикации текста
    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "send2"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleUploadComment), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Инициализаторы
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureViewComponents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Это необходимо для того, чтобы inputAccesoryView был правильно подобран из ограничений авторазметки
    
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
    
    // MARK: - Настройка внешнего вида окна
    
    /// Расставляем все необходимые UI компоненты на экране
    private func configureViewComponents(){
        
        
        addSubview(sendButton)
        sendButton.setPosition(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 44, height: 0)
        sendButton.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor).isActive = true
        
        addSubview(inputTextView)
        inputTextView.setPosition(top: topAnchor, left: leftAnchor, bottom: layoutMarginsGuide.bottomAnchor, right: sendButton.leftAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 8, paddingRight: 8, width: 0, height: 0)
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        addSubview(separatorView)
        separatorView.setPosition(top: topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    // MARK: - Вспомогательные функции
    
    ///Очищает поле ввода для комменатрия
    func clearCommentTextView() {
        inputTextView.text = nil
        inputTextView.placeHolder.isHidden = false
    }
    
    
    // MARK: - Обработка нажатия кнопок

    @objc func handleUploadComment() {
        guard let inputText = inputTextView.text else {return}
        delegate?.handleSendButton(forText: inputText)
    }
}
