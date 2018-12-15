//
//  PostHelper.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-11.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import Foundation

class PostHelper{
    private let host:String = "https://enigmatic-taiga-14768.herokuapp.com"
    var jwt:String
    init(jwt:String) {
        self.jwt = jwt
    }

    func getRecent(page:Int, completion: @escaping ([Post]?)->()){
        if page < 1 {return}
        let url = URL(string: "\(host)/posts/recent?page=\(page)")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(self.jwt, forHTTPHeaderField: "token")
        request.addValue("no-cache", forHTTPHeaderField: "cache-control")
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else{return}
            guard let data = data else{return}
            guard let httpResponse = response as? HTTPURLResponse else{return}
            if(httpResponse.statusCode != 200) {completion(nil);return}
            do{
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let jsonData = try decoder.decode([Post].self, from: data)
                if jsonData.count < 1{completion(nil)}
                else{completion(jsonData)}
            }catch let jsonErr{
                print("Failed to decode: \(jsonErr)")
            }
            
        }.resume()

    }
    
    func getTrending(page:Int, completion: @escaping ([Post]?)->()){
        if page<1{return}
        let url = URL(string: "\(host)/posts/trending?page=\(page)")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(self.jwt, forHTTPHeaderField: "token")
        request.addValue("no-cache", forHTTPHeaderField: "cache-control")
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else{return}
            guard let data = data else{return}
            guard let httpResponse = response as? HTTPURLResponse else{return}
            if(httpResponse.statusCode != 200) {completion(nil);return}
            do{
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let jsonData = try decoder.decode([Post].self, from: data)
                if jsonData.count < 1{completion(nil)}
                else{completion(jsonData)}
            }catch let jsonErr{
                print("Failed to decode: \(jsonErr)")
            }
            
        }.resume()
    }
    
    func getUserPosts(page:Int,userId:Int, completion: @escaping ([Post]?)->()){
        if page < 1{return}
        let url = URL(string: "\(host)/posts/\(userId)/posts?page=\(page)")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(self.jwt, forHTTPHeaderField: "token")
        request.addValue("no-cache", forHTTPHeaderField: "cache-control")
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else{return}
            guard let data = data else{return}
            guard let httpResponse = response as? HTTPURLResponse else{return}
            if(httpResponse.statusCode != 200) {completion(nil);return}
            do{
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let jsonData = try decoder.decode([Post].self, from: data)
                if jsonData.count < 1{completion(nil)}
                else{completion(jsonData)}
            }catch let jsonErr{
                print("Failed to decode: \(jsonErr)")
            }
        }.resume()

    }
    
    func vote(value:VoteValue,postId:Int, completion: @escaping (Bool)->()){
        var voteValue:Int
        switch value {
        case .up:
            voteValue = 1
        case .down:
            voteValue = -1
        case .none:
            return
        case .doubleUp:
            voteValue = 2
        case .doubleDown:
            voteValue = -2
        }
        let url = URL(string: "\(host)/posts/\(postId)/votes?value=\(voteValue)")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.addValue(self.jwt, forHTTPHeaderField: "token")
        request.addValue("no-cache", forHTTPHeaderField: "cache-control")
        
        session.dataTask(with: request) { (data, response, error) in
            guard error == nil else{return}
            guard let httpResponse = response as? HTTPURLResponse else{return}
            if(httpResponse.statusCode != 200){completion(false)}
            else{completion(true)}
        }.resume()

    }
    
    func post(content:String, completion:@escaping(Bool, Int?)->()){
        let url = URL(string: "\(host)/posts")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(self.jwt, forHTTPHeaderField: "token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters = ["content":content] as Dictionary<String, String>
        do{request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)}
        catch let error{print(error.localizedDescription);completion(false, nil);return}
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard error == nil else{completion(false, nil);return}
            guard let data = data else{completion(false, nil);return}
            guard let httpResponse = response as? HTTPURLResponse else{completion(false, nil);return}
            if httpResponse.statusCode != 201{completion(false, nil)}
            else{
                do{
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]{
                        let id = json["id"] as? Int
                        completion(true, id)
                    }
                }catch let error{print(error.localizedDescription);completion(false, nil);return}
            }
        }.resume()
    }
    
}

enum VoteValue {
    case up
    case down
    case none
    case doubleUp
    case doubleDown
}
