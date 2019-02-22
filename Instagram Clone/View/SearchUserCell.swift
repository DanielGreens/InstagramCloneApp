//
//  SearchUserCell.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 15/02/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import UIKit

class SearchUserCell: UITableViewCell {
    
    // MARK: - Свойства
    
    ///Данные о пользователе
    var user: User? {
        didSet{
            guard let profileImageUrl = user?.profileImageURL, let name = user?.name, let username = user?.username else{return}
            
            profileImageView.loadImage(with: profileImageUrl)
            self.textLabel?.text = username
            self.detailTextLabel?.text = name
        }
    }
    
    ///Аватар пользователя
    let profileImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = .lightGray
        image.layer.cornerRadius = 24
        return image
    }()
    
    
    // MARK: - Инициализаторы

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        profileImageView.setPosition(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Вспомогательные функции
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y - 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        
        detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        detailTextLabel?.textColor = .lightGray
        detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
    }
    
}
