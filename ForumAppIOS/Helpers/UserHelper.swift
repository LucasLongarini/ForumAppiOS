//
//  UserHelper.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-11.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import Foundation
import UIKit

class UserHelper{
    private let host:String = "https://enigmatic-taiga-14768.herokuapp.com"
    
    //logs in an existing user with the login credentials provoided(no name needed). Returns a jwt in the calllback
    func login(loginCredentials: LoginCredentials, completion: @escaping (_ token:String?, _ userId: Int?, _ error: String?)->()){
        let url = URL(string: "\(host)/users/login")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        let parameters = ["email":loginCredentials.email, "password":loginCredentials.password] as Dictionary<String, String>
        request.httpMethod = "POST"
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        }catch let error{
            print(error.localizedDescription)
            return
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard error == nil else {return}
            guard let data = data else {return}

            guard let httpResponse = response as? HTTPURLResponse else {return}
            
            do{
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]{
                    if httpResponse.statusCode == 200{
                        completion(json["token"] as? String, json["user_id"]as?Int, nil)
                    }
                    else{
                        completion(nil, nil, json["response"] as? String)
                    }
                }
            }catch let error{
                print(error.localizedDescription)
            }
        }.resume()
    }

    func register(loginCredentials:LoginCredentials, name:String, completion: @escaping (_ token:String?, _ userId:Int?, _ error:String?)->()){
        let url = URL(string: "\(host)/users/register")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let parameters = ["email":loginCredentials.email, "password":loginCredentials.password, "name":name] as Dictionary<String, String>
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
        }catch let error{
            print(error.localizedDescription)
            return
        }
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {return}
            guard let data = data else {return}
            guard let httpResponse = response as? HTTPURLResponse else {return}
            
            do{
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]{
                    if httpResponse.statusCode == 201{
                        completion(json["token"] as? String, json["user_id"]as?Int, nil)
                    }
                    else{
                        completion(nil, nil, json["response"] as? String)
                    }
                }
            }catch let error{
                print(error.localizedDescription)
            }
        }.resume()

    }
    
    func uploadImage(jwt:String, image:UIImage){
        let url = URL(string: "\(host)/users/picture")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(jwt, forHTTPHeaderField: "token")
        
        guard let data:Data = image.jpegData(compressionQuality: 1) else{return}
        request.httpBody = data
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {return}
            //guard let data = data else {return}
            guard let httpResponse = response as? HTTPURLResponse else {return}
            if httpResponse.statusCode == 201{
                print("Hurry Image upload worked")
            }else{
                print("Image upload failed with error:\(httpResponse.statusCode)")
            }
        }.resume()
        
    }
    
    func checkedLogin(jwt:String, completion: @escaping (Bool, Int?)->()){
        let url = URL(string: "\(host)/users/auth")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(jwt, forHTTPHeaderField: "token")
        request.addValue("no-cache", forHTTPHeaderField: "cache-control")
        session.dataTask(with: request as URLRequest){(data, response, error)in
            guard error == nil else{return}
            guard let data = data else {return}
            guard let httpResponse = response as? HTTPURLResponse else{return}
            do{
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]{
                    if httpResponse.statusCode == 200{
                        //logged in
                        completion(true, json["user_id"] as? Int)
                    }
                    else{
                        //not logged in
                        completion(false, nil)
                    }
                }
            }catch let error{
                print(error.localizedDescription)
            }
            
        }.resume()
    }
    
    func getUser(jwt:String, userId:Int, completion: @escaping (User?)->()){
        let url = URL(string: "\(host)/users/\(userId)")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(jwt, forHTTPHeaderField: "token")
        request.addValue("no-cache", forHTTPHeaderField: "cache-control")
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else{return}
            guard let data = data else {return}
            guard let httpResponse = response as? HTTPURLResponse else{return}
            if(httpResponse.statusCode != 200) {completion(nil);return}
            do{
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let jsonData = try decoder.decode(User.self, from: data)
                completion(jsonData)
            }catch let jsonErr{
                print("Failed to decode: \(jsonErr)")
            }
        }.resume()

    }
    
}
