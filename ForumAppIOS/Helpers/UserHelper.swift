//
//  UserHelper.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-11.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import Foundation

class UserHelper{
    private let host:String = "https://enigmatic-taiga-14768.herokuapp.com"

    //registers a new user with the login credentials provided. Returnes a jwt in the callback
    func register(loginCredentials:LoginCredentials, name:String){
        
        let url = URL(string: "\(host)/users/register")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        do{
            let encoder = JSONEncoder(); encoder.outputFormatting = .prettyPrinted
            request.httpBody = try encoder.encode(loginCredentials)
        }catch let error{
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            guard error == nil else {return}
            guard let data = data else {return}
            
            do{
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]{
                    print(json)
                }
            }catch let error{
                print(error.localizedDescription)
            }
        }.resume()
    }
    
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
}
