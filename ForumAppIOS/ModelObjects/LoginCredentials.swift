//
//  LoginCredentials.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-11.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import Foundation

class LoginCredentials: Codable {
    var email:String
    var password:String
    
    init(email:String, password:String) {
        self.email = email; self.password = password;
    }
}
