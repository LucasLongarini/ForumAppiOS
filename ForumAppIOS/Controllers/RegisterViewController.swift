//
//  RegisterViewController.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-16.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit
import CoreData

class RegisterViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profilePictureShadowView: UIView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var firstnameTextField: LoginFields!
    @IBOutlet weak var lastnameTextField: LoginFields!
    @IBOutlet weak var emailTextField: LoginFields!
    @IBOutlet weak var passwordTextField: LoginFields!
    @IBOutlet weak var reTypePasswordField: LoginFields!
    
    let userHelper:UserHelper = UserHelper()
    var pictureToUpload:UIImage?
    
    //data to send
    var jwt:String?
    var userId:Int?
    
    //CoreData
    var managedObjectContext:NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        self.view.addGradient(color1: UIColor(rgb: 0x808095), color2: UIColor(rgb: 0x313140))
        setupView()
        firstnameTextField.delegate = self
        lastnameTextField.delegate = self
        profilePicture.isUserInteractionEnabled = true
    }
    
    func setupView(){
        registerButton.layer.cornerRadius = registerButton.frame.height / 2
        profilePicture.layer.cornerRadius = profilePicture.frame.height / 2
        profilePictureShadowView.layer.cornerRadius = profilePictureShadowView.frame.height / 2
        
        profilePictureShadowView.addSoftShadow()
        profilePicture.clipsToBounds = true
        registerButton.addDropShadow()
        firstnameTextField.addDropShadow()
        lastnameTextField.addDropShadow()
        emailTextField.addDropShadow()
        passwordTextField.addDropShadow()
        reTypePasswordField.addDropShadow()
        
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        if firstnameTextField.text == "" || emailTextField.text == "" || passwordTextField.text == "" || reTypePasswordField.text == "" {
            registerButton.shake()
            return
        }
        
        if passwordTextField.text != reTypePasswordField.text{
            let alert = UIAlertController(title: nil, message: "Passwords don't match", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
            registerButton.shake()
            return
        }
        
        var name:String!
        if lastnameTextField.text == ""{
           name = "\(firstnameTextField.text!.lowercased())"
        }
        else{
            name = "\(firstnameTextField.text!.lowercased()) \(lastnameTextField.text!.lowercased())"
        }
        let credentials = LoginCredentials(email: emailTextField.text!, password: passwordTextField.text!)
        
        userHelper.register(loginCredentials: credentials, name: name) { (token, userID, error) in
            if let err = error{
                let alert = UIAlertController(title: "Registration Failed", message: err, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                DispatchQueue.main.async {self.present(alert, animated: true)}
                return
            }
            
            //need to save the jwt to CoreData
            let jwt = Token(context: self.managedObjectContext)
            jwt.token = token!
            do{try self.managedObjectContext.save()}
            catch{print("Could not save jwt \(error.localizedDescription)")}
            
            self.jwt = token
            self.userId = userID
            
            if let image = self.pictureToUpload{
                self.userHelper.uploadImage(jwt: token!, image: image)
                //save image to cache
                UIImageCache.shared.imageCache.setObject(image, forKey: "user-\(userID!)" as AnyObject)
            }
            
            //segue to main page and pass jwt and userID
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "RegisterToMain", sender: self)
            }
        }
        
    }
    
    @IBAction func profilePictureTapped(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Take a Picture", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Camera Roll", style: .default, handler: { (action) in
            let imageController = UIImagePickerController()
            imageController.delegate = self
            self.present(imageController, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        self.present(alert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.profilePicture.image = image
            pictureToUpload = image
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.isEqual(self.firstnameTextField) || textField.isEqual(lastnameTextField){
            return string.rangeOfCharacter(from: CharacterSet.letters.inverted) == nil
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RegisterToMain"{
            if let dest = segue.destination as? UITabBarController{
                if let main = (dest.viewControllers![0] as? UINavigationController)?.viewControllers[0] as? MainPageViewController{
                    main.jwt = self.jwt
                    main.userId = self.userId
                }
            }
        }
    }
    
    
}
