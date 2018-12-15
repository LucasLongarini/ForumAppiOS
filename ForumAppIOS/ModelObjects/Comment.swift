//
//  Comment.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-17.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import Foundation

class Comment: Decodable {
    
    init(id:Int, postId:Int, content:String, user:User?){
        self.id = id
        self.postId = postId
        self.content = content
        if let u = user{
            self.user = u
        }
        else{
            self.user = User()
        }
    }
    
    var id:Int = -1
    var postId:Int = -1
    var content:String = ""
    var votes: Int = 0
    var likeValue: Int = 0{
        didSet{
            if likeValue > 1{likeValue = 1}
            else if likeValue < -1{likeValue = -1}
        }
    }
    var user: User
    var timeElapsed: Int = 0
}
