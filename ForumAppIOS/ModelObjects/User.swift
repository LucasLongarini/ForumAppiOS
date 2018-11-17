//
//  User.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-11.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import Foundation

class User: Decodable {
    
    var id: Int? 
    var name:String?
    var pictureUrl:String?
    var totalLikes:Int?
    var totalPosts:Int?
}
