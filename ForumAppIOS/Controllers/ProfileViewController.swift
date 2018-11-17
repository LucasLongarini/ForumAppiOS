//
//  ProfileViewController.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-14.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profilePictureShadowView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var totalPostsLabel: UILabel!
    @IBOutlet weak var totalLikesLabel: UILabel!
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profilePictureHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var topViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var totalLikesView: UIView!
    @IBOutlet weak var totalPostsView: UIView!
    @IBOutlet weak var totalLikesHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var totalPostsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideViewSpacingConstraint: NSLayoutConstraint!
    
    let refreshControl: UIRefreshControl = UIRefreshControl()
    var posts:[Post]?
    var postHelper:PostHelper{
        get{
            return (((self.tabBarController?.viewControllers![0] as! UINavigationController).viewControllers[0] as! MainPageViewController).postHelper)
        }
    }
    var jwt:String?{
        get{
            return (((self.tabBarController?.viewControllers![0] as! UINavigationController).viewControllers[0] as! MainPageViewController).jwt)
        }
    }
    var userId:Int?{
        return (((self.tabBarController?.viewControllers![0] as! UINavigationController).viewControllers[0] as! MainPageViewController).userId)
    }
    var userHelper = UserHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        getPosts()
        getUser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.nameLabel.alpha = 1
        self.totalPostsLabel.alpha = 1
        self.totalLikesLabel.alpha = 1
    }
    
    func setUpView(){
        topViewConstraint.constant = -(view.frame.height / 4)
        topView.layer.cornerRadius = topView.frame.width / 2
        profilePictureHeightConstraint.constant = profilePicture.frame.height / 2
        profilePicture.layer.cornerRadius = profilePicture.frame.height / 2
        profilePicture.clipsToBounds = true
        profilePictureShadowView.layer.cornerRadius = profilePictureShadowView.frame.height / 2
        profilePicture.layer.borderWidth = 3 ;profilePicture.layer.borderColor = UIColor.white.cgColor
        totalLikesView.layer.borderWidth = 2 ;totalLikesView.layer.borderColor = UIColor.white.cgColor
        totalPostsView.layer.borderWidth = 2 ;totalPostsView.layer.borderColor = UIColor.white.cgColor
        
        totalLikesView.layer.cornerRadius = totalLikesView.frame.height / 2
        totalPostsView.layer.cornerRadius = totalPostsView.frame.height / 2

        totalLikesView.addSoftShadow()
        totalPostsView.addSoftShadow()
        profilePictureShadowView.addSoftShadow()
        
        let height:CGFloat
        let distance:Double = Double(sideViewSpacingConstraint!.constant + (totalLikesView.frame.width/2) + (profilePicture.frame.width/2))
        let radius:Double = Double(topView.frame.height / 2)
        height = CGFloat(radius - sqrt(pow(radius, 2)-pow(distance, 2)))
        totalLikesHeightConstraint.constant = -height
        totalPostsHeightConstraint.constant = -height
        
        tableView.delegate = self; tableView.dataSource = self
        
        guard let headerView = tableView.tableHeaderView else {return}
        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
            tableView.layoutIfNeeded()
        }
        
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshPosts(_:)), for: .valueChanged)
        refreshControl.tintColor = UIColor(rgb: 0xFEFEFE)
        self.nameLabel.alpha = 0
        self.totalPostsLabel.alpha = 0
        self.totalLikesLabel.alpha = 0
    }
    
    var page:Int = 1
    func getPosts(){
        guard let userId = self.userId else{return}
        postHelper.getUserPosts(page: page,userId:userId) { (posts) in
            if let p = posts{
                if self.posts == nil {self.posts = [Post]()}
                self.posts!.append(contentsOf: p)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func getUser(){
        guard let userId = self.userId else{return}
        guard let jwt = self.jwt else{return}
        userHelper.getUser(jwt:jwt, userId: userId) { (user) in
            guard let user = user else {return}
            if let pictureUrl = user.pictureUrl{
                self.profilePicture.loadImagesUsingCache(pictureUrl: pictureUrl)
            }
            DispatchQueue.main.async {
                self.nameLabel.text = user.name?.capitalized ?? ""
                self.totalLikesLabel.text = "\(user.totalLikes ?? 0)"
                self.totalPostsLabel.text = "\(user.totalPosts ?? 0)"
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let posts = self.posts else{return 0}
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        guard let posts = self.posts else{return cell}
        let post = posts[indexPath.row]

        cell.profilePicture.image = self.profilePicture.image
        
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

    @objc private func refreshPosts(_ sender: Any) {
        guard let userId = self.userId else{return}
        self.page = 1
        self.postHelper.getUserPosts(page: page, userId: userId) { (posts) in

            if let p = posts{
                if self.posts == nil {self.posts = [Post]()}
                else{self.posts!.removeAll()}
                self.posts!.append(contentsOf: p)
            }

            else if self.posts != nil{self.posts!.removeAll()}
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    

}
