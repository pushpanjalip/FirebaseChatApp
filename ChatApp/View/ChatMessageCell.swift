//
//  ChatMessageCell.swift
//  ChatApp
//
//  Created by Pushpanjali Pawar on 8/3/16.
//  Copyright © 2016 Pushpanjali Pawar. All rights reserved.
//

import UIKit
class ChatMessageCell:UICollectionViewCell{
    
    let textView:UITextView={
        let tv=UITextView()
        tv.text=""
        tv.font=UIFont.systemFontOfSize(16)
        tv.backgroundColor=UIColor.clearColor()
        tv.textColor = UIColor.whiteColor()
        tv.translatesAutoresizingMaskIntoConstraints=false
        return tv
    
    
    }()
    
    static let blueColor=UIColor(r: 0, g: 137, b: 249)
    
    let bubbleView:UIView={
        let view=UIView()
        view.backgroundColor=blueColor
        view.layer.cornerRadius=16
        view.layer.masksToBounds=true
        view.translatesAutoresizingMaskIntoConstraints=false
        return view
    
    
    }()
    
    let profileImageView:UIImageView={
        let imageView=UIImageView()
        imageView.layer.cornerRadius=16
        imageView.layer.masksToBounds=true
        imageView.contentMode = .ScaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints=false
        return imageView
    
    }()
    
    var bubbleWidthAnchor:NSLayoutConstraint?
    var bubbleRightAnchor:NSLayoutConstraint?
    var bubbleLeftAnchor:NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(bubbleView)
        addSubview(textView)
        addSubview(profileImageView)
        
        
        profileImageView.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 8).active=true
        profileImageView.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor).active=true //can be changed to center y of bubbleview
        profileImageView.widthAnchor.constraintEqualToConstant(32).active=true
        profileImageView.heightAnchor.constraintEqualToConstant(32).active=true
        
        
        bubbleRightAnchor = bubbleView.rightAnchor.constraintEqualToAnchor(self.rightAnchor,constant: -10)
        bubbleRightAnchor?.active = true
        bubbleView.topAnchor.constraintEqualToAnchor(self.topAnchor).active=true
        
        bubbleLeftAnchor=bubbleView.leftAnchor.constraintEqualToAnchor(profileImageView.rightAnchor, constant: 8)
        bubbleLeftAnchor?.active=false   //keep default as false
        
        bubbleWidthAnchor = bubbleView.widthAnchor.constraintEqualToConstant(200)
        bubbleWidthAnchor?.active = true
        bubbleView.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active=true
        
        //textView.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active=true
        //add padding from left
        textView.leftAnchor.constraintEqualToAnchor(bubbleView.leftAnchor, constant: 8).active=true
        
        textView.topAnchor.constraintEqualToAnchor(self.topAnchor).active=true
        //textView.widthAnchor.constraintEqualToConstant(200).active=true
        textView.rightAnchor.constraintEqualToAnchor(bubbleView.rightAnchor).active=true
        textView.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active=true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}
