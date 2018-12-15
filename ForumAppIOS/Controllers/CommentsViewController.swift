//
//  CommentsViewController.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-17.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

class CommentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate{
    
    
    @IBOutlet weak var tableView: UITableView!
    var post:Post!
    var jwt:String!
    var postHelper:PostHelper!
    var commentHelper:CommentHelper!
    var comments:[Comment]?
    let refreshControl: UIRefreshControl = UIRefreshControl()

    
    //accessoryView 
    @IBOutlet weak var accessoryBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var profilePicHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var accessoryView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var postHeightConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self; tableView.delegate = self
        //tableView.keyboardDismissMode = .interactive
        commentTextView.delegate = self
        commentHelper = CommentHelper(jwt: self.jwt)
        setupKeyboardObservers()
        getComments()
        setupView()
        refreshControl.addTarget(self, action: #selector(refreshComments), for: .valueChanged)
    }
    
    func setupView(){
        tableView.refreshControl = refreshControl
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 30
        profilePicHeightConstraint.constant = commentTextView.frame.height
        profilePicture.layer.cornerRadius = commentTextView.frame.height / 2
        profilePicture.clipsToBounds = true
        profilePicture.layer.borderWidth = 0.5
        profilePicture.layer.borderColor = UIColor.lightGray.cgColor
        profilePicture.image = PersonalUserSingleton.shared.image
        borderView.layer.cornerRadius = borderView.frame.height / 2
        borderView.layer.borderWidth = 0.5
        borderView.layer.borderColor = UIColor.lightGray.cgColor
        commentTextView.text = "Write a Comment..."
        commentTextView.textColor = UIColor.lightGray
        accessoryView.layer.borderWidth = 0.5
        accessoryView.layer.borderColor = UIColor.lightGray.cgColor
        postButton.alpha = 0
        postHeightConstraint.constant = borderView.frame.height
    }
    
    func getComments(){
        commentHelper.getComments(forPost: post.id) { (results) in
            if let comments = results{
                if self.comments == nil{self.comments = [Comment]()}
                self.comments!.append(contentsOf: comments)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        }
    }
    
    @objc func refreshComments(){
        commentHelper.getComments(forPost: post.id) { (results) in
            if let com = results{
                if self.comments == nil {self.comments = [Comment]()}
                else {self.comments!.removeAll()}
                self.comments!.append(contentsOf: com)
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    @IBAction func postButtonPressed(_ sender: Any) {
        let trimmedString = self.commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        commentHelper.comment(onPost: self.post.id, content: trimmedString) { (success,id) in
            if success{
                guard let commentId = id else{return}
                let comment = Comment(id: commentId, postId: self.post.id, content: trimmedString, user: PersonalUserSingleton.shared.user)
                if self.comments == nil{self.comments = [Comment]()}
                self.comments!.append(comment)
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath(row: max((self.comments!.count - 1), 0), section: 1)], with: .bottom)
                    self.tableView.endUpdates()
                    //self.tableView.reloadData()
                    self.commentTextView.text = "Write a Comment..."
                    self.commentTextView.textColor = UIColor.lightGray
                    self.postButton.isUserInteractionEnabled = false
                    self.postButton.alpha = 0
                    self.commentTextView.resignFirstResponder()
                }
            }
            else{print("error")}
        }
    }
    
    func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardWillShow(notification:NSNotification){
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue{
            let keyboardHeight = keyboardFrame.cgRectValue.height
            let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ??  0.4
            let keyboardCurve = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 0
            if self.commentTextView.textColor == UIColor.lightGray{
                commentTextView.selectedTextRange = commentTextView.textRange(from: commentTextView.beginningOfDocument, to: commentTextView.beginningOfDocument)
                togglePostButton(on: false)
            }else{togglePostButton(on: true)}
            accessoryBottomContraint.constant = -(keyboardHeight-bottomView.frame.height-1)
            UIView.animate(withDuration: keyboardDuration, delay: 0, options: UIView.AnimationOptions(rawValue: keyboardCurve), animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @objc func handleKeyboardWillHide(notification:NSNotification){
        if commentTextView.textColor == UIColor.lightGray{
            postButton.alpha = 0
            postButton.isUserInteractionEnabled = false
        }
        let keyboardDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ??  0.4
        let keyboardCurve = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 0
        accessoryBottomContraint.constant = 1
        UIView.animate(withDuration: keyboardDuration, delay: 0, options: UIView.AnimationOptions(rawValue: keyboardCurve), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        cancelButton.isEnabled = false
        cancelButton.tintColor = UIColor.clear
        commentTextView.resignFirstResponder()
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        commentTextView.resignFirstResponder()
    }
    
    func togglePostButton(on:Bool){
        if postButton.isUserInteractionEnabled && !on{
            postButton.isUserInteractionEnabled = false
            postButton.alpha = 0.5
        }
        else if !postButton.isUserInteractionEnabled && on{
            postButton.isUserInteractionEnabled = true
            postButton.alpha = 1
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        reSizeTextView(textView: textView, animation: true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {
            togglePostButton(on: false)
            textView.text = "Write a Comment..."
            textView.textColor = UIColor.lightGray
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
            
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, set
            // the text color to black then set its text to the
            // replacement string
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            togglePostButton(on: true)
            textView.textColor = UIColor.darkGray
            textView.text = text
        }
            
            // For every other case, the text should change with the usual
            // behavior...
        else {
            let maxLength = 200
            let currentString:NSString = textView.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: text) as NSString
            return newString.length <= maxLength
        }
        // ...otherwise return false since the updates have already
        // been made
        return false
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        cancelButton.isEnabled = true
        cancelButton.tintColor = UIColor.white
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        cancelButton.isEnabled = false
        cancelButton.tintColor = UIColor.clear
    }
    
    func reSizeTextView(textView:UITextView, animation:Bool){
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        if estimatedSize.height != textView.frame.height{
            textView.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height{
                    constraint.constant = estimatedSize.height
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                        self.view.layoutIfNeeded()
                    }, completion: nil)
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
           return 1
        }
        else if section == 1{
            //comments
            guard let comments = self.comments else{return 0}
            return comments.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
            if let pictureUrl = post.user.pictureUrl{
                cell.profilePicture.loadImagesUsingCache(pictureUrl: pictureUrl)
            }else{
                cell.profilePicture.image = UIImage(named: "StockProfilePic")!
            }
            cell.content.text = post.content
            cell.name.text = post.user.name?.capitalized ?? "Deleted User"
            cell.setTimestamp(seconds: post.timeElapsed)
            cell.commentsButton.setTitle((post.comments<1 ? "no " : "\(post.comments) ")+((post.comments==1) ? "comment":"comments"), for: .normal)
            cell.postId = post.id
            cell.voteLabel.text = "\(post.votes)"
            cell.postHelper = self.postHelper
            cell.setVoteValue(value: post.likeValue)
            
            if cell.commentsButton.isUserInteractionEnabled{cell.commentsButton.isUserInteractionEnabled = false}
            return cell
        }
        
        else if indexPath.section == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            if let comments = self.comments{
                let comment = comments[indexPath.row]
                if let pictureUrl = comment.user.pictureUrl{
                    cell.profilePicture.loadImagesUsingCache(pictureUrl: pictureUrl)
                }else{
                    cell.profilePicture.image = UIImage(named: "StockProfilePic")!
                }
                cell.contentLabel.text = comment.content
                cell.nameLabel.text = comment.user.name?.capitalized ?? "Deleted User"
                cell.setVoteValue(value: comment.likeValue)
                cell.setTimestamp(seconds: comment.timeElapsed)
                cell.postId = comment.postId
                cell.id = comment.id
                cell.voteLabel.text = "\(comment.votes)"
                cell.commentHelper = self.commentHelper
                if comments.count > 1 {
                    if indexPath.row == 0{cell.bound = .top}
                    else if indexPath.row == comments.count - 1 {cell.bound = .bottom}
                    else{cell.bound = .middle}
                }
            }
            return cell
        }
        else{
            return UITableViewCell(style: .default, reuseIdentifier: "default")
        }
    }
    

}
