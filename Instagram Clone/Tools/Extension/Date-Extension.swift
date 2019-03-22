//
//  Date-Extension.swift
//  Instagram Clone
//
//  Created by Даниил Омельчук on 22/03/2019.
//  Copyright © 2019 Даниил Омельчук. All rights reserved.
//

import Foundation

///Отображение времени публикации поста в новостной ленте
extension Date {
    
    ///Переводит время с момента публикации поста в человеческий вид
    func timeAgoToDisplay() -> String {
        
        //Получаем количество секунд которые прошли с момента публикации поста
        let seccondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        let part: Int
        let unit: String
        
        if seccondsAgo < minute {
            part = seccondsAgo
            unit = "СЕКУНД"
        }
        else if seccondsAgo < hour {
            part = seccondsAgo / minute
            unit = "МИНУТ"
        }
        else if seccondsAgo < day {
            part = seccondsAgo / hour
            unit = "ЧАСОВ"
        }
        else if seccondsAgo < week {
            part = seccondsAgo / day
            unit = "ДНЕЙ"
        }
        else if seccondsAgo < month {
            part = seccondsAgo / week
            unit = "НЕДЕЛЬ"
        }
        else {
            part = seccondsAgo / month
            unit = "МЕСЯЦЕВ"
        }
        
        return "\(part) \(unit) НАЗАД"
    }
}
