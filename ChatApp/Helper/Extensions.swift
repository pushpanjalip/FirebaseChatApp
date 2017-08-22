//
//  Extensions.swift
//  ChatApp
//
//  Created by Pushpanjali Pawar on 8/1/16.
//  Copyright © 2016 Pushpanjali Pawar. All rights reserved.
//

import UIKit

let imageCache=NSCache()   //to cache images so that memory and network usage canbe optimized


extension UIImageView{
    func loadImageUsingCacheWithUrlString(urlString:String){
        //check for image cache
        if let cacheImage = imageCache.objectForKey(urlString) as? UIImage{
            self.image=cacheImage
            return
        
        }
        
        let url=NSURL(string: urlString)
        NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
            if error != nil{
                print(error)
                return
                
            }
            dispatch_async(dispatch_get_main_queue(), {
                if let downloadedImage=UIImage(data: data!)
                {
                    imageCache.setObject(downloadedImage, forKey: urlString)
                    self.image=downloadedImage
                
                }
                
                
            })
            
        }).resume()

    }

}
extension UIColor
{
    convenience init(r:CGFloat,g:CGFloat,b:CGFloat) {
        self.init(red:r/255,green: g/255,blue: b/255,alpha: 1)
    }
}
