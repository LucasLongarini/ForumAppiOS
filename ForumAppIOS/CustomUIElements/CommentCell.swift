//
//  CommentCell.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-17.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

enum CommentCellBound {
    case top
    case middle
    case bottom
    case none
}


class CommentCell: UITableViewCell {

    @IBOutlet weak var sideViewTopContraint: NSLayoutConstraint!
    @IBOutlet weak var sideViewBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var voteLabel: UILabel!
    var postId:Int!
    var id:Int!
    var commentHelper:CommentHelper?
    var voteValue:VoteValue = .none
    var stockButtonColor:UIColor!
    var likedButtonColor:UIColor = UIColor(rgb: 0x615F71)
    var bound:CommentCellBound = .none{
        didSet{
            changeSideView()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        stockButtonColor = upVoteButton.tintColor
        backView.layer.cornerRadius = 5
        profilePicture.layer.cornerRadius = profilePicture.frame.height / 2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderWidth = 1.5
        profilePicture.layer.borderColor = UIColor(rgb: 0xD8D8D8).cgColor
        sideView.layer.cornerRadius = sideView.frame.width / 2
        
        backView.addDropShadow()
    }
    
    func changeSideView(){
        switch bound {
        case .top:
            sideViewBottomContraint.constant = 30
        case .middle:
            sideViewBottomContraint.constant = 30
            sideViewTopContraint.constant = -30
        case .bottom:
            sideViewTopContraint.constant = -30
        case .none:
            break;
        }
    }
    
    func setVoteValue(value:Int){
        switch value{
        case -1:
            voteValue = .down
            upVoteButton.tintColor = stockButtonColor
            downVoteButton.tintColor = likedButtonColor
        case 0:
            voteValue = .none
            downVoteButton.tintColor = stockButtonColor
            upVoteButton.tintColor = stockButtonColor
        case 1:
            voteValue = .up
            upVoteButton.tintColor = likedButtonColor
            downVoteButton.tintColor = stockButtonColor
        default:
            print("Error in setVoteValue: \(value) is not a valid value. Enter (-1, 0 , 1)")
            return
        }
    }
    
    
    @IBAction func upVoteButtonPressed(_ sender: Any) {
        guard let commentHelper = self.commentHelper else{return}
        let originalLikeValue:Int = Int(self.voteLabel.text!)!
        //already pressed(unlike)
        if self.voteValue == .up{
            //change instantly
            self.voteLabel.text = "\(originalLikeValue - 1)"
            (sender as! UIButton).tintColor = stockButtonColor
            self.voteValue = .none
            
            commentHelper.vote(value: .down, commentId: self.id) { (success) in
                //revert changes
                if !success{
                    self.voteValue = .up
                    DispatchQueue.main.async {
                        self.voteLabel.text = "\(originalLikeValue + 1)"
                        (sender as! UIButton).tintColor = self.likedButtonColor
                    }
                }
            }
        }
        //not pressed(like)
        else if self.voteValue == .none{
            //change instantly
            self.voteLabel.text = "\(originalLikeValue + 1)"
            (sender as! UIButton).tintColor = likedButtonColor
            self.voteValue = .up
            
            commentHelper.vote(value: .up, commentId: id) { (success) in
                //revert changes
                if !success{
                    self.voteValue = .none
                    DispatchQueue.main.async{
                        self.voteLabel.text = "\(originalLikeValue - 1)"
                        (sender as! UIButton).tintColor = self.stockButtonColor
                    }
                }
            }
        }
        //disliked(like)
        else if self.voteValue == .down{
            //change instantly
            self.voteLabel.text = "\(originalLikeValue + 2)"
            (sender as! UIButton).tintColor = likedButtonColor
            self.downVoteButton.tintColor = stockButtonColor
            self.voteValue = .up
            
            commentHelper.vote(value: .doubleUp, commentId: id) { (success) in
                //revert changes
                if !success{
                    self.voteValue = .down
                    DispatchQueue.main.async{
                        self.voteLabel.text = "\(originalLikeValue - 2)"
                        (sender as! UIButton).tintColor = self.stockButtonColor
                        self.downVoteButton.tintColor = self.likedButtonColor
                    }
                }
            }
        }
    }
    
    @IBAction func downVoteButtonPressed(_ sender: Any) {
        guard let commentHelper = self.commentHelper else{return}
        let originalLikeValue:Int = Int(self.voteLabel.text!)!
        //already pressed (un dislike)
        if self.voteValue == .down {
            //change instantly
            self.voteLabel.text = "\(originalLikeValue + 1)"
            (sender as! UIButton).tintColor = stockButtonColor
            self.voteValue = .none
            
            commentHelper.vote(value: .up, commentId: id) { (successful) in
                //revert changes
                if !successful {
                    self.voteValue = .down
                    DispatchQueue.main.async {
                        self.voteLabel.text = "\(originalLikeValue - 1)"
                        (sender as! UIButton).tintColor = self.likedButtonColor
                    }
                }
            }
        }
        //not pressed (dilike)
        else if self.voteValue == .none{
            //change instantly
            self.voteLabel.text = "\(originalLikeValue - 1)"
            (sender as! UIButton).tintColor = likedButtonColor
            self.voteValue = .down
            
            commentHelper.vote(value: .down, commentId: id) { (successful) in
                //revert changes
                if !successful{
                    self.voteValue = .none
                    DispatchQueue.main.async{
                        self.voteLabel.text = "\(originalLikeValue + 1)"
                        (sender as! UIButton).tintColor = self.stockButtonColor
                    }
                }
            }
        }
        //liked (dislike)
        else if self.voteValue == .up{
            //change instantly
            self.voteLabel.text = "\(originalLikeValue - 2)"
            (sender as! UIButton).tintColor = likedButtonColor
            self.upVoteButton.tintColor = stockButtonColor
            self.voteValue = .down
            
            commentHelper.vote(value: .doubleDown, commentId: id) { (successful) in
                //revert changes
                if !successful{
                    self.voteValue = .up
                    DispatchQueue.main.async{
                        self.voteLabel.text = "\(originalLikeValue + 2)"
                        (sender as! UIButton).tintColor = self.stockButtonColor
                        self.upVoteButton.tintColor = self.likedButtonColor
                    }
                }
            }
        }
    }
    
    func setTimestamp(seconds:Int){
        if seconds == 0{
            timestampLabel.text = "just now"
        }
        //seconds
        else if seconds < 60{
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
