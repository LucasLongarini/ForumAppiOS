//
//  ProfileViewController.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-14.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var topViewSizeConstraint: NSLayoutConstraint!
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()

    }
    
    func setUpView(){
        topViewConstraint.constant = -(view.frame.height / 4)
        topView.layer.cornerRadius = topView.frame.height / 2
        profilePictureHeightConstraint.constant = profilePicture.frame.height / 2
        profilePicture.layer.cornerRadius = profilePicture.frame.height / 2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderWidth = 3 ;profilePicture.layer.borderColor = UIColor.white.cgColor
        totalLikesView.layer.borderWidth = 2 ;totalLikesView.layer.borderColor = UIColor.white.cgColor
        totalPostsView.layer.borderWidth = 2 ;totalPostsView.layer.borderColor = UIColor.white.cgColor
        
        totalLikesView.layer.cornerRadius = totalLikesView.frame.height / 2
        totalPostsView.layer.cornerRadius = totalPostsView.frame.height / 2

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

        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        if offset < -50{
            let scale = (-(offset + 50)/100)+1
            topView.transform = CGAffineTransform(scaleX: scale, y: scale)

        }
    }

}
