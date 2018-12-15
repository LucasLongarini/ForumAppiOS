//
//  User.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-11.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import Foundation

class User: Decodable {
    
    var userId: Int?
    var name:String?
    var pictureUrl:String?
    var totalLikes:Int?
    var totalPosts:Int?
    
    init(id:Int, name:String,pictureUrl:String?, totalLikes:Int, totalPosts:Int){
        self.userId = id
        self.name = name
        self.pictureUrl = pictureUrl
        self.totalLikes = totalLikes
        self.totalPosts = totalPosts
    }
    
    init(){
        
    }
    
}
