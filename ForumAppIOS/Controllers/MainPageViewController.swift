//
//  MainPageViewController.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-11.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit
import CoreData

class MainPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,PostCellDelegate, PostCreatedDelegate {
    
    @IBOutlet weak var segmentedView: TabbedSegmentedControl!
    @IBOutlet weak var segmentedTopConstraint: NSLayoutConstraint!
    var jwt:String?
    var userId:Int?
    var recentPosts:[Post] = [Post]()
    var trendingPosts:[Post] = [Post]()
    @IBOutlet weak var tableView: UITableView!
    var managedObjectContext:NSManagedObjectContext!
    var postHelper:PostHelper!
    let refreshControl: UIRefreshControl = UIRefreshControl()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        if jwt == nil{self.jwt = getjwt()}
        guard let jwt = self.jwt else{return }//maybe display error message and take back to login screen
        postHelper = PostHelper(jwt: jwt)

        postHelper.getRecent(page: 1) { (results) in
            if let posts = results{
                self.recentPosts.append(contentsOf: posts)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    func setupView(){
        self.tabBarController?.delegate = UIApplication.shared.delegate as? UITabBarControllerDelegate
        tableView.dataSource = self; tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 30
        tableView.contentInset = UIEdgeInsets(top: self.segmentedView.frame.height + 2.5, left: 0, bottom: 2.5, right: 0)
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshPosts(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor(rgb: 0xFEFEFE)
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
    
    var recentPage:Int = 1
    func getRecentPosts(){
        postHelper.getRecent(page: recentPage) { (results) in
            if let posts = results{
                self.recentPosts.append(contentsOf: posts)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    var trendingPage:Int = 1
    func getTrendingPosts(){
        postHelper.getTrending(page: trendingPage) { (results) in
            if let posts = results{
                self.trendingPosts.append(contentsOf: posts)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recentPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        let post = self.recentPosts[indexPath.row]
        
        if post.user.userId == userId{cell.profilePicture.image = PersonalUserSingleton.shared.image}
        else if let pictureUrl = post.user.pictureUrl{cell.profilePicture.loadImagesUsingCache(pictureUrl: pictureUrl)}
        else{cell.profilePicture.image = UIImage(named: "StockProfilePic")!}
        
        cell.delegate = self
        cell.postIndex = indexPath.row
        cell.name.text = post.user.name?.capitalized ?? "Deleted User"
        cell.content.text = post.content
        cell.setTimestamp(seconds: post.timeElapsed)
        if post.comments == 0{cell.commentsButton.setTitle("Write a comment", for: .normal)}
        else{cell.commentsButton.setTitle("\(post.comments) "+((post.comments==1) ? "Comment":"Comments"), for: .normal)}
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
    
    @objc private func refreshPosts(_ sender: Any) {
        postHelper.getRecent(page: 1) { (results) in
            if let posts = results{
                self.recentPosts.removeAll()
                self.recentPosts.append(contentsOf: posts)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    @IBAction func segmentedViewChanged(_ sender: Any) {
        self.tableView.reloadData()
    }
    
    var postToSend:Post!
    func commentsPressed(postIndex: Int) {
        postToSend = self.recentPosts[postIndex]
        performSegue(withIdentifier: "MainToComments", sender: self)
    }
    
    func postCreated(post: Post) {
        recentPosts.insert(post, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("YUH")
        if segue.identifier == "MainToComments"{
            if let dest = segue.destination as? CommentsViewController{
                dest.post = self.postToSend
                dest.jwt = self.jwt!
                dest.postHelper = self.postHelper
            }
        }
    }
}
