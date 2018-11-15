//
//  MainPageViewController.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-11.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit
import CoreData

class MainPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var segmentedView: TabbedSegmentedControl!
    @IBOutlet weak var segmentedTopConstraint: NSLayoutConstraint!
    var jwt:String?
    var posts:[Post] = [Post]()
    @IBOutlet weak var tableView: UITableView!
    var managedObjectContext:NSManagedObjectContext!
    var postHelper:PostHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self; tableView.delegate = self
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 30
        tableView.contentInset = UIEdgeInsets(top: self.segmentedView.frame.height + 2.5, left: 0, bottom: 2.5, right: 0)
        if jwt == nil{self.jwt = getjwt()}
        guard let jwt = self.jwt else{return }//maybe display error message and take back to login screen
        postHelper = PostHelper(jwt: jwt)

        postHelper.getRecent(page: 1) { (results) in
            if let posts = results{
                self.posts.append(contentsOf: posts)
                print(posts.count)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }

    }
    
    func getjwt()->String?{
        let jwtRequest:NSFetchRequest<Token> = Token.fetchRequest()
        do{
            let results = try managedObjectContext.fetch(jwtRequest)
            if results.count > 0{
                return results[0].token
            }
            else{
                print("error retrieving jwt from core data: no results")
                return nil
            }
        }
        catch{print("error retrieving jwt from core data:\(error.localizedDescription)")}
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
        let post = self.posts[indexPath.row]
        if let pictureUrl = post.user.pictureUrl{
            cell.profilePicture.loadImagesUsingCache(pictureUrl: pictureUrl)
        }else{
            cell.profilePicture.image = UIImage(named: "StockProfilePic")!
        }
        cell.name.text = post.user.name?.capitalized ?? "Deleted User"
        cell.content.text = post.content
        cell.setTimestamp(seconds: post.timeElapsed)
        cell.commentsButton.setTitle((post.comments<1 ? "no " : "\(post.comments) ")+((post.comments==1) ? "comment":"comments"), for: .normal)
        cell.postId = post.id
        cell.voteLabel.text = "\(post.votes)"
        cell.postHelper = self.postHelper
        cell.setVoteValue(value: post.likeValue)
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y + segmentedView.frame.height + 2.5) < 0{
            segmentedTopConstraint.constant = -(scrollView.contentOffset.y + segmentedView.frame.height + 2.5) - 5
            self.view.layoutIfNeeded()
        }
        else{
            segmentedTopConstraint.constant = -5
        }
    }
    
}
