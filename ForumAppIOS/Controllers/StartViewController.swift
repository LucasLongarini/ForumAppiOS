//
//  StartViewController.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-11.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit
import CoreData

class StartViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var loadingView: LoadingIcon!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var rightLine: UIView!
    @IBOutlet weak var leftLine: UIView!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var passwordTextField: LoginFields!
    @IBOutlet weak var emailTextField: LoginFields!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailFieldConstraint: NSLayoutConstraint!
    
    var userHelper = UserHelper()
    var managedObjectContext:NSManagedObjectContext!
    var token:String?
    var userId:Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.view.addGradient(color1: UIColor(rgb: 0x808095), color2: UIColor(rgb: 0x313140))
        registerButton.layer.cornerRadius = registerButton.frame.height / 2
        loginButton.layer.cornerRadius = loginButton.frame.height / 2
        loadingView.stopAnimating()
        passwordTextField.addDropShadow(); emailTextField.addDropShadow(); registerButton.addDropShadow();loginButton.addDropShadow()
        passwordTextField.delegate = self
        emailTextField.delegate = self
        
        setupAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        doAnimation()
    }
    
    func doAnimation(){

        UIView.animate(withDuration: 0.5, animations: {
            self.titleLabel.alpha = 1
        }) { (bool) in
            UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
                self.emailTextField.alpha = 1
                self.passwordTextField.alpha = 1
                self.iconImageView.alpha = 1
            }, completion: nil)
        }
        UIView.animate(withDuration: 1, delay: 0.5, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
            self.emailFieldConstraint.constant = 30
            self.view.layoutIfNeeded()
        }, completion: nil)
        UIView.animate(withDuration: 0.6, delay: 1, options: .curveEaseIn, animations: {
            self.registerButton.alpha = 1
            self.loginButton.alpha = 1
            self.orLabel.alpha = 1
            self.leftLine.alpha = 1
            self.rightLine.alpha = 1
        }, completion: nil)
    }
    
    func setupAnimation(){
        self.orLabel.alpha = 0
        self.leftLine.alpha = 0
        self.rightLine.alpha = 0
        self.titleLabel.alpha = 0
        self.emailTextField.alpha = 0
        self.passwordTextField.alpha = 0
        self.emailFieldConstraint.constant = -10
        self.registerButton.alpha = 0
        self.loginButton.alpha = 0
        self.iconImageView.alpha = 0
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isEqual(self.emailTextField){
            self.passwordTextField.becomeFirstResponder()
        }
        else if textField.isEqual(self.passwordTextField){
            self.view.endEditing(true)
            login()
        }
        return true
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        login()
    }
    
    func login(){
        guard let email = emailTextField.text else{loginButton.shake();return}
        guard let password = passwordTextField.text else{loginButton.shake();return}
        if(email == "" || password == ""){loginButton.shake(); return}
        let credentials = LoginCredentials(email: email, password: password)
        loadingView.startAnimating()
        userHelper.login(loginCredentials: credentials) { (token, user_id, error) in
            if error != nil{
                let alert = UIAlertController(title: "Login Failed", message: "Email or Password incorrect", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                
                DispatchQueue.main.async {
                    self.loginButton.shake()
                    self.loadingView.stopAnimating()
                    self.present(alert, animated: true)
                }
            }
            else{
                let jwt = Token(context: self.managedObjectContext)
                jwt.token = token!
                do{try self.managedObjectContext.save()}
                catch{print("Could not save jwt \(error.localizedDescription)")}
                DispatchQueue.main.async {
                    self.loadingView.stopAnimating()
                    self.performSegue(withIdentifier: "LoginToMain", sender: self)
                }
                self.token = token
                self.userId = user_id
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginToMain"{
            if let dest = segue.destination as? UITabBarController{
                if let main = (dest.viewControllers![0] as? UINavigationController)?.viewControllers[0] as? MainPageViewController{
                    main.jwt = self.token
                    main.userId = self.userId
                }
            }
        }
    }
    @IBAction func backgroundTouched(_ sender: Any) {
        self.view.endEditing(true)
    }
    
}
