//
//  PersonalUserSingleton.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-19.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class PersonalUserSingleton {
    
    static let shared = PersonalUserSingleton()
    
    var jwt:String = ""
    var user:User?
    var image: UIImage = UIImage(named: "ProfileIcon")!
    func updateUser(user:User){
        self.user = user
    }
    func updateImage(imageURL: String?){
        guard let pictureUrl = imageURL else{return}
        let host = "https://res.cloudinary.com/dsgtzloau/image/upload/v1540361869"
        let url = URL(string: "\(host)/\(pictureUrl)")!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            if let downloadedImage = UIImage(data: data!){
                self.image = downloadedImage
            }
            
        }.resume()
    }
    
}
