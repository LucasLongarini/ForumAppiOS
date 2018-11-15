//
//  TabbedSegmentControll.swift
//  ForumAppIOS
//
//  Created by Lucas Longarini on 2018-11-11.
//  Copyright © 2018 Lucas Longarini. All rights reserved.
//

import UIKit

@IBDesignable
class TabbedSegmentedControl: UIControl {
    
    var buttons = [UIButton]()
    var selector: UIView!
    var selectedSegmentIndex: Int = 0
    
    @IBInspectable
    var textColor: UIColor = UIColor.lightGray{
        didSet{
            updateView()
        }
    }
    
    @IBInspectable
    var fontSize: Int = 14{
        didSet{
            selectedFont = selectedFont.withSize(CGFloat(fontSize + 5))
            normalFont = normalFont.withSize(CGFloat(fontSize))
            updateView()
        }
    }
    
    var selectedFont: UIFont = UIFont.boldSystemFont(ofSize: 16)
    
    var normalFont: UIFont = UIFont.systemFont(ofSize: 14)
    
    @IBInspectable
    var selectedTextColor: UIColor = UIColor.darkGray{
        didSet{
            updateView()
        }
    }
    
    @IBInspectable
    var commaSeperatedButtons: String = ""{
        didSet{
            updateView()
        }
    }
    
    @IBInspectable
    var selectorColor: UIColor = UIColor.darkGray{
        didSet{
            updateView()
        }
    }
    
    override func draw(_ rect: CGRect) {
        
    }
    
    func updateView(){
        buttons.removeAll()
        subviews.forEach { $0.removeFromSuperview()}
        
        let buttonTitles = commaSeperatedButtons.components(separatedBy: ",")
        for str in buttonTitles{
            let button = UIButton(type: .system)
            button.setTitle(str, for: .normal)
            button.titleLabel?.font = normalFont
            button.setTitleColor(textColor, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
            buttons.append(button)
        }
        buttons[0].setTitleColor(selectedTextColor, for: .normal)
        buttons[0].titleLabel?.font = selectedFont
        //create selector
        let selectorWidth = frame.width / CGFloat(buttons.count)
        let selectorHeight = frame.height * (0.1)
        selector = UIView(frame: CGRect(x: 0, y: frame.height - selectorHeight , width: selectorWidth, height: selectorHeight))
        selector.backgroundColor = selectorColor
        //selector.layer.cornerRadius = selector.frame.height / 2
        addSubview(selector)
        
        
        let sv = UIStackView(arrangedSubviews: buttons)
        sv.alignment = .fill
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        addSubview(sv)
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        sv.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        sv.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        sv.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
    }
    
    @objc func buttonTapped(button: UIButton){
        for (index, btn) in buttons.enumerated(){
            btn.setTitleColor(textColor, for: .normal)
            btn.titleLabel?.font = normalFont
            if btn == button{
                self.selectedSegmentIndex = index
                btn.setTitleColor(selectedTextColor, for: .normal)
                btn.titleLabel?.font = selectedFont
                let selectorPosition = frame.width / CGFloat(buttons.count) * CGFloat(index)
                UIView.animate(withDuration: 0.3) {
                    self.selector.frame.origin.x = selectorPosition
                }
            }
        }
        sendActions(for: .valueChanged)
    }
    
    func switchIndex(index: Int){
        if index > buttons.count - 1{
            return
        }else{
            self.selectedSegmentIndex = index
            for(i,btn) in buttons.enumerated(){
                btn.setTitleColor(textColor, for: .normal)
                btn.titleLabel?.font = normalFont
                if i == index{
                    btn.setTitleColor(selectedTextColor, for: .normal)
                    btn.titleLabel?.font = selectedFont
                }
            }
        }
    }
    
}
