//
//  PostCell.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-11.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var voteLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var timestampLabel: UILabel!
    var postId: Int = 0
    var postHelper:PostHelper?
    var voteValue: VoteValue = .none
    var stockButtonColor: UIColor!
    var likedButtonColor:UIColor = UIColor(rgb: 0x615F71)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        stockButtonColor = upVoteButton.tintColor
        backView.layer.cornerRadius = 5
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.height / 2
        self.profilePicture.clipsToBounds = true
        self.profilePicture.layer.borderWidth = 1.5
        self.profilePicture.layer.borderColor = UIColor.darkGray.cgColor
        self.backView.addDropShadow()
    }
    
    func setVoteValue(value:Int){
        switch value {
        case -1:
            voteValue = .down
            downVoteButton.tintColor = likedButtonColor
        case 0:
            voteValue = .none
        case 1:
            voteValue = .up
            upVoteButton.tintColor = likedButtonColor
        default:
            print("Error in setVoteValue: \(value) is not a valid value. Enter (-1, 0 , 1)")
            return
        }
    }
    
    @IBAction func upVotePressed(_ sender: UIButton) {
        guard let postHelper = self.postHelper else{return}
        let originalLikeValue:Int = Int(self.voteLabel.text!)!
        //already pressed (unlike)
        if self.voteValue == .up {
            //change instantly
            self.voteLabel.text = "\(originalLikeValue - 1)"
            sender.tintColor = stockButtonColor
             self.voteValue = .none
            
            postHelper.vote(value: .down, postId: self.postId) { (successful) in
                //revert changes
                if !successful {
                    self.voteValue = .up
                    DispatchQueue.main.async {
                        self.voteLabel.text = "\(originalLikeValue + 1)"
                        sender.tintColor = self.likedButtonColor
                    }
                }
            }
        }
        //not pressed (like)
        else if self.voteValue == .none{
            //change instantly
            self.voteLabel.text = "\(originalLikeValue + 1)"
            sender.tintColor = likedButtonColor
            self.voteValue = .up

            
            postHelper.vote(value: .up, postId: self.postId) { (successful) in
                //revert changes
                if !successful{
                    self.voteValue = .none
                    DispatchQueue.main.async{
                        self.voteLabel.text = "\(originalLikeValue - 1)"
                        sender.tintColor = self.stockButtonColor
                    }
                }
            }
        }
        //disliked (like)
        else if self.voteValue == .down{
            //change instantly
            self.voteLabel.text = "\(originalLikeValue + 2)"
            sender.tintColor = likedButtonColor
            self.downVoteButton.tintColor = stockButtonColor
            self.voteValue = .up
            
            postHelper.vote(value: .doubleUp, postId: self.postId) { (successful) in
                //revert changes
                if !successful{
                    self.voteValue = .down
                    DispatchQueue.main.async{
                        self.voteLabel.text = "\(originalLikeValue - 2)"
                        sender.tintColor = self.stockButtonColor
                        self.downVoteButton.tintColor = self.likedButtonColor
                    }
                }
            }
        }
    }
    

    @IBAction func downVotePressed(_ sender: UIButton) {
        guard let postHelper = self.postHelper else{return}
        let originalLikeValue:Int = Int(self.voteLabel.text!)!
        //already pressed (un dislike)
        if self.voteValue == .down {
            //change instantly
            self.voteLabel.text = "\(originalLikeValue + 1)"
            sender.tintColor = stockButtonColor
            self.voteValue = .none
            
            postHelper.vote(value: .up, postId: self.postId) { (successful) in
                //revert changes
                if !successful {
                    self.voteValue = .down
                    DispatchQueue.main.async {
                        self.voteLabel.text = "\(originalLikeValue - 1)"
                        sender.tintColor = self.likedButtonColor
                    }
                }
            }
        }
        //not pressed (dilike)
        else if self.voteValue == .none{
            //change instantly
            self.voteLabel.text = "\(originalLikeValue - 1)"
            sender.tintColor = likedButtonColor
            self.voteValue = .down
            
            
            postHelper.vote(value: .down, postId: self.postId) { (successful) in
                //revert changes
                if !successful{
                    self.voteValue = .none
                    DispatchQueue.main.async{
                        self.voteLabel.text = "\(originalLikeValue + 1)"
                        sender.tintColor = self.stockButtonColor
                    }
                }
            }
        }
        //liked (dislike)
        else if self.voteValue == .up{
            //change instantly
            self.voteLabel.text = "\(originalLikeValue - 2)"
            sender.tintColor = likedButtonColor
            self.upVoteButton.tintColor = stockButtonColor
            self.voteValue = .down
            
            postHelper.vote(value: .doubleDown, postId: self.postId) { (successful) in
                //revert changes
                if !successful{
                    self.voteValue = .up
                    DispatchQueue.main.async{
                        self.voteLabel.text = "\(originalLikeValue + 2)"
                        sender.tintColor = self.stockButtonColor
                        self.upVoteButton.tintColor = self.likedButtonColor
                    }
                }
            }
        }
    }
    

    func setTimestamp(seconds:Int){
        //seconds
        if seconds < 60{
            timestampLabel.text = "\(seconds) "+(seconds==1 ? "second" : "seconds")+" ago"
        }
        //minutes
        else if seconds < 3600{
            let minutes:Int = seconds/60
            timestampLabel.text = "\(minutes) "+(minutes==1 ? "minute" : "minutes")+" ago"
        }
        //hours
        else if seconds < 86400{
            let hours:Int = seconds/3600
            timestampLabel.text = "\(hours) "+(hours==1 ? "hour" : "hours")+" ago"
        }
        //days
        else if seconds < 604800{
            let days:Int = seconds/86400
            timestampLabel.text = "\(days) "+(days==1 ? "day" : "days")+" ago"
        }
        //weeks
        else if seconds < 2628000{
            let weeks:Int = seconds/604800
            timestampLabel.text = "\(weeks) "+(weeks==1 ? "week" : "weeks")+" ago"
        }
        //months
        else if seconds < 31540000{
            let months:Int = seconds/2628000
            timestampLabel.text = "\(months) "+(months==1 ? "month" : "months")+" ago"
        }
        //years
        else{
            let years:Int = seconds/31540000
            timestampLabel.text = "\(years) "+(years==1 ? "year" : "years")+" ago"
        }
    }
}

