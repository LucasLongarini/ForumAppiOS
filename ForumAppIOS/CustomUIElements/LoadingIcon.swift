//
//  LoadingIcon.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-14.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

@IBDesignable
class LoadingIcon:UIView{

    @IBInspectable
    var cornerRadius:CGFloat = 0{
        didSet{
            updateView()
        }
    }
    
    @IBInspectable
    var loadingIcon:UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge){
        didSet{
            updateView()
        }
    }
    
    func updateView(){
        subviews.forEach { $0.removeFromSuperview()}
        self.layer.cornerRadius = self.cornerRadius
        loadingIcon.center = CGPoint(x: self.frame.size.width  / 2, y: self.frame.size.height / 2)
        loadingIcon.hidesWhenStopped = true
        self.addSubview(loadingIcon)
        loadingIcon.startAnimating()
    }
    
    func stopAnimating(){
        loadingIcon.stopAnimating()
        self.alpha = 0
    }
    
    func startAnimating(){
        loadingIcon.startAnimating()
        self.alpha = 1
    }
}
