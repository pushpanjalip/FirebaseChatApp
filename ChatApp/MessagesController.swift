//
//  ViewController.swift
//  ChatApp
//
//  Created by Pushpanjali Pawar on 7/29/16.
//  Copyright © 2016 Pushpanjali Pawar. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
 let cellId="cell"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem=UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem=UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(handleNewMessage))
        //user is not logged in
       
        checkIfUserLoggedIn()
        //observeMessages()
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: cellId)
        
    }
    var messages=[Message]()
    var messageDictionary=[String:Message]()
    
    func observeMessages(){
        
        //get the current user
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref=FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let messageId=snapshot.key
            let messageReference=FIRDatabase.database().reference().child("messages").child(messageId)
            
            messageReference.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let dictionary=snapshot.value as? [String:AnyObject]{
                    let message=Message()
                    message.setValuesForKeysWithDictionary(dictionary)
                    if let chatPartnerId=message.chatPartnerId(){
                        self.messageDictionary[chatPartnerId]=message
                        self.messages=Array(self.messageDictionary.values)
                        self.messages.sortInPlace({ (message1, message2) -> Bool in
                            return message1.timeStamp?.intValue>message2.timeStamp?.intValue
                        })
                        
                    }
                    self.timer?.invalidate()
                    print("we jst cancelled our timer")
                    self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                    
                    print("")
                    
                    
                }
                }, withCancelBlock: nil)
            }, withCancelBlock: nil)
        
    }
    var timer:NSTimer?
    
    func handleReloadTable(){
        dispatch_async(dispatch_get_main_queue(), {
            print("reload")
            self.tableView.reloadData()
        })
    
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //let cell=UITableViewCell(style: .Subtitle, reuseIdentifier:cellId)
       let cell=tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! UserCell
        let message=messages[indexPath.row]
        cell.message=message
        return cell
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let message=messages[indexPath.row]
        
        guard let chatPartnerId  = message.chatPartnerId() else {
            return
        }
        
        let ref=FIRDatabase.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            guard let dictionary=snapshot.value as? [String:AnyObject]
            else
            {
                return
            
            }
            let user=User()
            user.id=chatPartnerId
            user.setValuesForKeysWithDictionary(dictionary)
            self.showChatControllerForUser(user)
            }, withCancelBlock: nil)
    }
    func handleNewMessage()
    {
    
        let newMessageController = NewMessageController()
        newMessageController.messagesController=self
        
        let navController=UINavigationController(rootViewController: newMessageController)
        presentViewController(navController, animated: true, completion: nil)
    }
    func checkIfUserLoggedIn()
    {
        if FIRAuth.auth()?.currentUser?.uid == nil
        {
            performSelector(#selector(handleLogout), withObject: nil, afterDelay: 0)
        }
        //if user is logged in get user name
        else
        {
             self.fetchUserAndSetUpNavBarTitle()
            
        }
        
    }
    func fetchUserAndSetUpNavBarTitle()
    {
        guard let uid=FIRAuth.auth()?.currentUser?.uid else {return}
        //following is the structure at Firebase database
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            if let dictionary=snapshot.value as? [String:AnyObject]
            {
               // self.navigationItem.title=dictionary["name"] as? String
                
                let user = User()
                user.setValuesForKeysWithDictionary(dictionary)
                self.setUpNavBarWithUser(user)

            }
                        // print(snapshot)  //snapshot is response dictionary from firebase:-
            //Snap (EcByytEPUlVNyaKKKZdi07a8rdI3) {
            // email = "Test3@gmail.com";
            // name = Amruta;
            // }
            }, withCancelBlock: nil)

    }
    func setUpNavBarWithUser(user:User)
    {
        
        messages.removeAll()
        messageDictionary.removeAll()
        self.tableView.reloadData()
        
        observeMessages()
        
        
        //self.navigationItem.title=user.name
        let titleView=UIView()
        titleView.frame=CGRect(x: 0, y: 0, width: 100, height: 40)
        
        /*add this third view to make title view increase width as label*/
        let containerView=UIView()
        containerView.translatesAutoresizingMaskIntoConstraints=false
        titleView.addSubview(containerView)
        
        let profileImageView=UIImageView()
        profileImageView.contentMode = .ScaleAspectFill
        profileImageView.layer.cornerRadius=20
        profileImageView.clipsToBounds=true
        profileImageView.translatesAutoresizingMaskIntoConstraints=false
        if let profileImageUrl=user.profileImageURL{
        profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        containerView.addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraintEqualToAnchor(containerView.leftAnchor).active=true
        profileImageView.centerYAnchor.constraintEqualToAnchor(containerView.centerYAnchor).active=true
        profileImageView.widthAnchor.constraintEqualToConstant(40).active=true
        profileImageView.heightAnchor.constraintEqualToConstant(40).active=true
        
        let nameLabel=UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text=user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        nameLabel.leftAnchor.constraintEqualToAnchor(profileImageView.rightAnchor, constant: 8).active=true
        nameLabel.centerYAnchor.constraintEqualToAnchor(profileImageView.centerYAnchor).active=true
        nameLabel.rightAnchor.constraintEqualToAnchor(containerView.rightAnchor).active=true
        nameLabel.heightAnchor.constraintEqualToAnchor(profileImageView.heightAnchor).active=true
        
        containerView.centerXAnchor.constraintEqualToAnchor(titleView.centerXAnchor).active=true
        containerView.centerYAnchor.constraintEqualToAnchor(titleView.centerYAnchor).active=true
        self.navigationItem.titleView=titleView
        //titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatControllerForUser(<#T##user: User##User#>))))
    
    }
    func showChatControllerForUser(user:User){
        let chatController=chatLogController(collectionViewLayout:UICollectionViewFlowLayout())
        chatController.user=user
        navigationController?.pushViewController(chatController, animated: true)
    
    }
    func handleLogout()
    {
        do
        {try FIRAuth.auth()?.signOut()
        }catch let logouterror
        {
            print(logouterror)
        }
        let loginController=LogInController()
        loginController.messagesController=self
        presentViewController(loginController, animated: true, completion: nil)
    }

}

