//
//  InputTextView.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 02/04/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit

///Класс представляет текстовое поле для ввода сообщения
class InputTextView: UITextView, UITextViewDelegate {
    
    // MARK: - Свойства
    
    ///Плейсхолдер для commentTextView "Введите комменатрий"
    let placeHolder: UILabel = {
        let label = UILabel()
        label.text = "Введите текст"
        label.textColor = .lightGray
        return label
    }()
    
    ///Максимальная высота commentTextView до того как он станет прокручиваемым
    lazy var maxUnScrollableHeight: CGFloat = {
        return UIScreen.main.bounds.size.height / 8
    }()
    
    private var heightConstraint: NSLayoutConstraint!
    
    // MARK: - Инициализаторы
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        self.delegate = self
        
        //Создаем констраинт высоты для textView, но пока он не активен
        heightConstraint = self.heightAnchor.constraint(equalToConstant: self.contentSize.height)
        
        //Для того чтобы убирать плейсхолдер как только текст не равен пустой строке
        NotificationCenter.default.addObserver(self, selector: #selector(handleInputTextChange), name: UITextView.textDidChangeNotification, object: nil)
        
        addSubview(placeHolder)
        placeHolder.setPosition(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        placeHolder.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("DeInit")
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
    }
    
    //Этот метод вызывается каждый раз когда система понимает что нужно перерисовать какой либо объект
    //Например когда текст не помещается по ширине в textView добавляется новая строка, этот метод вызовется
    //Но он не вызовется когда мы начнем удалять введенный текст, так как он будет умещатбся в уже увеличенные textView. Чтобы этот метод вызывался и в этом случае, в методе func textViewDidChange мы вызываем принудительное выполнение этого метода путем вызова метода setNeedsLayout()
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //Если высота содержимого (текста) больше чем максимально допустимая высота для textView которую мы установили
        if self.contentSize.height >= self.maxUnScrollableHeight {
            //То если, констраинт высота не активен
            if heightConstraint.isActive == false {
                //Устанавливаем для него значение константы в значение текущей высоты содержимого
                heightConstraint.constant = contentSize.height
                //Делаем констраинт активным
                heightConstraint.isActive = true
            }
            //Делаем элемент прокручиваемым
            self.isScrollEnabled = true
        }
            //Иначе
        else {
            //Делаем элемент снова не прокручиваемым
            self.isScrollEnabled = false
            //Если констраинт был установлен ранее, то делаем его не активным
            if heightConstraint.isActive == true {
                heightConstraint.isActive = false
            }
            //Вычисляем необходимую высоту, для текущего текста в textView
            let contentSize = self.sizeThatFits(self.bounds.size)
            var frame = self.frame
            frame.size.height = contentSize.height
            self.frame = frame
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        //Принудительно обновляем макет представления
        setNeedsLayout()
    }
    
    // MARK: - Обработка событий
    
    @objc func handleInputTextChange() {
        //Когда текст пустой показываем плейсхолдер
        placeHolder.isHidden = !self.text.isEmpty
    }
}
