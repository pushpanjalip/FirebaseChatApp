//
//  UserCell.swift
//  ChatApp
//
//  Created by Pushpanjali Pawar on 8/2/16.
//  Copyright © 2016 Pushpanjali Pawar. All rights reserved.
//

import UIKit
import Firebase
class UserCell:UITableViewCell
{
    var message:Message?{
        didSet{
        
            setUpNameAndProfileImage()
            
            self.detailTextLabel?.text=message?.text
            
            if let seconds=message?.timeStamp?.doubleValue{
                let timeStampDate=NSDate(timeIntervalSince1970: seconds)
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.stringFromDate(timeStampDate)
                
            }

        }
    
    
    }
    
    private func setUpNameAndProfileImage(){
        
//        let chatPartnerId:String?
//        if message?.fromId == FIRAuth.auth()?.currentUser?.uid
//        {
//            chatPartnerId = message?.toId
//        
//        }
//        else{
//            chatPartnerId = message?.fromId
//        
//        }
        if let id=message?.chatPartnerId(){
            let ref=FIRDatabase.database().reference().child("users").child(id)
            ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dictionary=snapshot.value as? [String:AnyObject]{
                    self.textLabel?.text=dictionary["name"] as? String
                    if let profileImageUrl=dictionary["profileImageURL"] as? String{
                        self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                    }
                    
                }
                }, withCancelBlock: nil)
            
        }

    
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame=CGRectMake(64, textLabel!.frame.origin.y-2, textLabel!.frame.width, textLabel!.frame.height)
        detailTextLabel?.frame=CGRectMake(64, detailTextLabel!.frame.origin.y+2,detailTextLabel!.frame.width, detailTextLabel!.frame.height)
    }
    let profileImageView:UIImageView={
        
        let imageView=UIImageView()
        imageView.image=UIImage(named: "rose")
        imageView.layer.cornerRadius=24
        imageView.layer.masksToBounds=true
        imageView.contentMode = .ScaleAspectFill
        return imageView
        
    }()
    let timeLabel:UILabel={
        let label=UILabel()
        label.font=UIFont.systemFontOfSize(12)
        label.textColor = UIColor.lightGrayColor()
        label.translatesAutoresizingMaskIntoConstraints=false
        return label
    
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
        profileImageView.translatesAutoresizingMaskIntoConstraints=false
        //add image view in cell
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        //add constraints to image view
        profileImageView.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 8).active=true //8 pixels from left
        profileImageView.centerYAnchor.constraintEqualToAnchor(self.centerYAnchor).active=true
        profileImageView.widthAnchor.constraintEqualToConstant(48).active=true
        profileImageView.heightAnchor.constraintEqualToConstant(48).active=true
        
        
        timeLabel.rightAnchor.constraintEqualToAnchor(self.rightAnchor).active=true
        timeLabel.topAnchor.constraintEqualToAnchor(self.topAnchor,constant: 18).active=true
        timeLabel.widthAnchor.constraintEqualToConstant(100).active=true
        timeLabel.heightAnchor.constraintEqualToAnchor(textLabel?.heightAnchor).active=true
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

