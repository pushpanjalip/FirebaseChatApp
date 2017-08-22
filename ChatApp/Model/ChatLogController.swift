//
//  ChatLogController.swift
//  ChatApp
//
//  Created by Pushpanjali Pawar on 8/2/16.
//  Copyright © 2016 Pushpanjali Pawar. All rights reserved.
//

import UIKit
import Firebase
class chatLogController:UICollectionViewController,UITextFieldDelegate,UICollectionViewDelegateFlowLayout  {
    
    let cellId="cell"
    var user:User?{
        didSet{
            navigationItem.title=user?.name
            observeMessages()
        
        }
    
    }
    var messages=[Message]()
    func observeMessages()
    {
        guard let uid=FIRAuth.auth()?.currentUser?.uid else {
            return
        
        }
        
        //get all messages of a user
        let userMessagesRef=FIRDatabase.database().reference().child("user-messages").child(uid)
        userMessagesRef.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let messageID=snapshot.key
            let messageRef=FIRDatabase.database().reference().child("messages").child(messageID)
            messageRef.observeEventType(.Value, withBlock: { (snapshot) in
                guard let dictionary=snapshot.value as? [String:AnyObject]
                    else {
                        return
                }
                let message = Message()
                message.setValuesForKeysWithDictionary(dictionary)
                
                if message.chatPartnerId() == self.user?.id{
                self.messages.append(message)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.collectionView?.reloadData()
                    })

                }
                
                
                
                }, withCancelBlock: nil)
            }, withCancelBlock: nil)
    
    }
    
    lazy var inputTextField:UITextField={
        let textField=UITextField()
        textField.delegate=self
        textField.placeholder="Enter message...."
        textField.translatesAutoresizingMaskIntoConstraints=false
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //top padding for collection view
        collectionView?.contentInset=UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
       
        //scrolling inset
        //collectionView?.scrollIndicatorInsets=UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.keyboardDismissMode = .Interactive
        collectionView?.backgroundColor=UIColor.whiteColor()
        collectionView?.registerClass(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
              // setUpKeyboardObservers()
    }
    
    lazy var inputContainerView : UIView = {
        let containerView = UIView()
        containerView.frame=CGRect(x: 0, y: 0, width:self.view.frame.width, height: 50)
        containerView.backgroundColor = .whiteColor()
        
        
        let sendButton=UIButton()
        sendButton.setTitle("Send", forState: .Normal)
        sendButton.setTitleColor(UIColor(r:0,g:137,b:249), forState: .Normal)
        sendButton.addTarget(self, action: #selector(handleSendMessage), forControlEvents: .TouchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints=false
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active=true
        sendButton.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active=true
        sendButton.widthAnchor.constraintEqualToConstant(80).active=true
        sendButton.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor).active=true
        
        
        containerView.addSubview(self.inputTextField)
        
        self.inputTextField.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor,constant: 8).active=true
        self.inputTextField.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active=true
        self.inputTextField.rightAnchor.constraintEqualToAnchor(sendButton.leftAnchor).active=true
        self.inputTextField.heightAnchor.constraintEqualToAnchor(containerView.heightAnchor).active=true
        
        let separatorLineView=UIView()
        separatorLineView.backgroundColor=UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints=false
        containerView.addSubview(separatorLineView)
        separatorLineView.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active=true
        separatorLineView.topAnchor.constraintEqualToAnchor(containerView.topAnchor).active=true
        separatorLineView.widthAnchor.constraintEqualToAnchor(containerView.widthAnchor).active=true
        separatorLineView.heightAnchor.constraintEqualToConstant(1).active=true
        
        return containerView

    
    
    }()
    
    override var inputAccessoryView: UIView?{
        get{
            
            return inputContainerView
        
        }
    
    
    }
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    func setUpKeyboardObservers(){
        
        //this will notify whenever keyboard is shown
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        
        
        //hide
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    
    }
    func handleKeyboardWillShow(notification:NSNotification){
        //print(notification.userInfo)
        let keyboardFrame=notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue()
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        let keyboardDuration=notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        
        
        UIView.animateWithDuration(keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
        
    
    }
    func handleKeyboardWillHide(notification:NSNotification){
        containerViewBottomAnchor?.constant=0
        let keyboardDuration=notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue
        
        
        UIView.animateWithDuration(keyboardDuration!) {
            self.view.layoutIfNeeded()
        }

    
    
    }
    //this is needed to avoid memory leak so remove the notification observers
    
    
   override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(true)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    
    }
    var containerViewBottomAnchor:NSLayoutConstraint?
        func handleSendMessage()
    {
        let ref=FIRDatabase.database().reference().child("messages")
        let childRef=ref.childByAutoId()//generates a new child location using a unique key and returns a FIRDatabaseReference to it.children of a Firebase Database location represent a list of items.
        let toId=user!.id!
        let fromId=FIRAuth.auth()!.currentUser!.uid
        let timeStamp:NSNumber=Int(NSDate().timeIntervalSince1970)
        let values=["text":inputTextField.text!,"toId":toId,"fromId":fromId,"timeStamp":timeStamp]
        
        //childRef.updateChildValues(values)
        
        //to enable multiple user chat
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error)
                return
            }
            self.inputTextField.text=nil
            let userMessagesRef=FIRDatabase.database().reference().child("user-messages").child(fromId)
            let messageId=childRef.key
            userMessagesRef.updateChildValues([messageId:1])
            
            let recipientUserMessageRef=FIRDatabase.database().reference().child("user-messages").child(toId)
            recipientUserMessageRef.updateChildValues([messageId:1])    
            
            
        }
        
    
    }
    //to enable enter
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        handleSendMessage()
        return true
    }
    
    
    //Collection View Methods
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCellWithReuseIdentifier(cellId, forIndexPath: indexPath) as! ChatMessageCell
        let message=messages[indexPath.row]
        cell.textView.text=message.text
        setUpCell(cell, message: message)
        
        cell.bubbleWidthAnchor?.constant=estimateFrameOfText(message.text!).width+32
        return cell
    }
    
    private func setUpCell(cell:ChatMessageCell,message:Message)
    {
        
        if let profileImageUrl=self.user?.profileImageURL{
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        
        }
        
        if message.fromId==FIRAuth.auth()?.currentUser?.uid{
            //outgoing blue msg from current user
            
            cell.bubbleView.backgroundColor=ChatMessageCell.blueColor
            cell.textView.textColor = .whiteColor()
            cell.profileImageView.hidden=true
            
            
            cell.bubbleRightAnchor?.active=true
            cell.bubbleLeftAnchor?.active=false
            
            
        }
        else{
            //incoming gray msg
            cell.bubbleView.backgroundColor=UIColor(r: 240, g: 240, b: 240)
            cell.textView.textColor = .blackColor()
            cell.profileImageView.hidden=false
            //make gray bubble to the left
            
            cell.bubbleRightAnchor?.active=false
            cell.bubbleLeftAnchor?.active=true
            
            
        }

    
    }
    
    //FlowLayout methods
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        var height:CGFloat = 80
        if let text = messages[indexPath.item].text{
            height = estimateFrameOfText(text).height + 20
        
        }
        
        let width=UIScreen.mainScreen().bounds.width
        return CGSize(width: width, height: height)
    }
    private func estimateFrameOfText(text:String) -> CGRect{
        let size=CGSize(width: 200, height: 1000)
        let options=NSStringDrawingOptions.UsesFontLeading.union(.UsesLineFragmentOrigin)
        return NSString(string: text).boundingRectWithSize(size, options: options, attributes:[NSFontAttributeName:UIFont.systemFontOfSize(16)], context: nil)
    
    }
    
    //this method gets called whenever device rotates
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()   //in landscape it will show messages towards right only
    }
    
}