//
//  Message.swift
//  ChatApp
//
//  Created by Pushpanjali Pawar on 8/2/16.
//  Copyright © 2016 Pushpanjali Pawar. All rights reserved.
//

import UIKit
import Firebase
class Message: NSObject {
    var fromId:String?
    var toId:String?
    var text:String?
    var timeStamp:NSNumber?
    
    func chatPartnerId() -> String?{
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }

}
