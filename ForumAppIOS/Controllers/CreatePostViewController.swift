//
//  CreatePostViewController.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-18.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

protocol PostCreatedDelegate {
    func postCreated(post:Post)
}

class CreatePostViewController: UIViewController, UITextViewDelegate {

    var delegate: PostCreatedDelegate?
    @IBOutlet weak var accessoryView: UIView!
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var charactersLabel: UILabel!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var postHelper:PostHelper=PostHelper(jwt: PersonalUserSingleton.shared.jwt)
    var userId:Int?=PersonalUserSingleton.shared.user?.userId
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        setupView()
        setupKeyboardObservers()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        UIApplication.shared.statusBarStyle = .default
        
    }
    
    func setupView(){
        reSizeTextView(textView: self.textView)
        togglePostButton(on: false)
        self.textView.text = "Write Something..."
        textView.textColor = .lightGray
        profilePicture.layer.cornerRadius = profilePicture.frame.width / 2
        profilePicture.clipsToBounds = true
        postButton.layer.cornerRadius = postButton.frame.height / 2
        profilePicture.layer.borderWidth = 1.5
        profilePicture.layer.borderColor = UIColor(rgb: 0xD8D8D8).cgColor
        profilePicture.image = PersonalUserSingleton.shared.image
        accessoryView.layer.borderWidth = 0.5
        accessoryView.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    @IBAction func postNavButtonPressed(_ sender: Any) {
        post()
    }
    
    @IBAction func postAccessoryButtonPressed(_ sender: Any) {
        post()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    var isEmpty:Bool = true
    func post(){
        if isEmpty{}
        else{
            let content:String = textView.text
            let trimmedString = content.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedString.count != 0{
                postHelper.post(content: trimmedString) { (success, postId)  in
                    if success{
                        if let id = postId{
                            guard let del = self.delegate else{return}
                            DispatchQueue.main.async {
                                del.postCreated(post:Post(id: id, content: trimmedString, user: PersonalUserSingleton.shared.user))
                            }
                        }
                        self.dismiss(animated: true, completion: nil)
                    }
                    else{print("Uh Oh something has gone wrong")}
                }
            }
        }
    }
    
    func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardWillShow(notification:NSNotification){
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue{
            let keyboardHeight = keyboardFrame.cgRectValue.height
            bottomViewConstraint.constant = keyboardHeight-1
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleKeyboardWillHide(notification:NSNotification){
        bottomViewConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func reSizeTextView(textView:UITextView){
        let size = CGSize(width: textView.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        if estimatedSize.height != textView.frame.height{
            textView.constraints.forEach { (constraint) in
                if constraint.firstAttribute == .height{
                    constraint.constant = estimatedSize.height*1.5
                }
            }
        }
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
        reSizeTextView(textView: textView)
        charactersLabel.text = "\(textView.text.count)/200 Characters"
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            // Combine the textView text and the replacement text to
            // create the updated text string
            let currentText:String = textView.text
            let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
            
            // If updated text view will be empty, add the placeholder
            // and set the cursor to the beginning of the text view
            if updatedText.isEmpty {
                isEmpty = true
                togglePostButton(on: false)
                charactersLabel.text = "0/200 Characters"
                textView.text = "Write Something..."
                textView.textColor = UIColor.lightGray
                
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
                
                // Else if the text view's placeholder is showing and the
                // length of the replacement string is greater than 0, set
                // the text color to black then set its text to the
                // replacement string
            else if textView.textColor == UIColor.lightGray && !text.isEmpty {
                togglePostButton(on: true)
                isEmpty = false
                textView.textColor = UIColor.darkGray
                textView.text = text
                charactersLabel.text = "\(text.count)/200 Characters"
            }
                
                // For every other case, the text should change with the usual
                // behavior...
            else {
                isEmpty = false
                let maxLength = 200
                let currentString:NSString = textView.text! as NSString
                let newString: NSString =
                    currentString.replacingCharacters(in: range, with: text) as NSString
                return newString.length <= maxLength
                //return true
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
    
}
