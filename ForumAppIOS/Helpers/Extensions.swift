//
//  Extensions.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-11.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

let ImageCache = NSCache<AnyObject, AnyObject>()
extension UIImageView{
    func loadImagesUsingCache(pictureUrl:String){
        ImageCache.countLimit = 100
        
        //check cache for image first
        if let cachedImage = ImageCache.object(forKey: pictureUrl as AnyObject) as? UIImage{
            DispatchQueue.main.async {
                self.image = cachedImage
            }
            return
        }
        let host = "https://res.cloudinary.com/dsgtzloau/image/upload/v1540361869"
        let url = URL(string: "\(host)/\(pictureUrl)")
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!){
                    ImageCache.setObject(downloadedImage, forKey: pictureUrl as AnyObject)
                    self.image = downloadedImage
                }
            }
            
        }.resume()
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension UIView{
    func addGradient(color1: UIColor, color2: UIColor){
        let layer = CAGradientLayer()
        layer.frame = self.bounds
        layer.colors = [color1.cgColor, color2.cgColor]

        self.layer.insertSublayer(layer, at: 0)
    }
}

extension UIView{
    func addDropShadow(){
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.5
        layer.masksToBounds = false;
        clipsToBounds = false;
        
    }

    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
    
}

