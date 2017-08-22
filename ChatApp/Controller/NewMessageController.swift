//
//  NewMessageController.swift
//  ChatApp
//
//  Created by Pushpanjali Pawar on 7/29/16.
//  Copyright © 2016 Pushpanjali Pawar. All rights reserved.
//

import UIKit
import Firebase
class NewMessageController: UITableViewController {

    let cellId="cell"
    var users=[User]()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem=UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(handleCancel))
        tableView.registerClass(UserCell.self, forCellReuseIdentifier: cellId)
        fetchUser()
    }
    func fetchUser()
    {
        FIRDatabase.database().reference().child("users").observeEventType(.ChildAdded, withBlock: { (snapshot) in
            if let dictionary=snapshot.value as? [String:AnyObject]
            {
                let user = User()
                //get the unique id for each user
                user.id=snapshot.key
                
                //if the below setter is used then ur app will crash if class properties does not match firebase keys
                
                user.setValuesForKeysWithDictionary(dictionary)
                //other way to do it
               // user.name = dictionary["name"] as? String
                //user.email = dictionary["email"] as? String
                self.users.append(user)
                //this will crash because of background thread so lets use dispatch_async to fix
                dispatch_async(dispatch_get_main_queue(), { 
                    self.tableView.reloadData()
                })
                
                
               // print(user.name)
                
            }
            
            }, withCancelBlock: nil)
    }
    func handleCancel()
    {
    
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as! UserCell
        let user=users[indexPath.row]
        cell.textLabel?.text=user.name
        cell.detailTextLabel?.text=user.email
        cell.profileImageView.image=UIImage(named: "rose")  //placeholder image
        if let profileImageURL=user.profileImageURL{
                 cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageURL)
        }
        
        return cell
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 72
    }
    var messagesController:MessagesController?
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dismissViewControllerAnimated(true) {
            let user=self.users[indexPath.row]
           self.messagesController?.showChatControllerForUser(user)
        }
    }
   }

