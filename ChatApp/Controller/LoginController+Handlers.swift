//
//  LoginController+Handlers.swift
//  ChatApp
//
//  Created by Pushpanjali Pawar on 8/1/16.
//  Copyright © 2016 Pushpanjali Pawar. All rights reserved.
//

import UIKit
import Firebase
extension LogInController:UIImagePickerControllerDelegate,UINavigationControllerDelegate
{
func handleSelectProfImage()
{
    let picker=UIImagePickerController()
    picker.delegate=self
    picker.allowsEditing=true
    presentViewController(picker, animated: true, completion: nil)
    
}
    /*Picker Delegate Method*/
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        var selectedImageFromPicker:UIImage?
        if let editedImage=info["UIImagePickerControllerEditedImage"] as? UIImage
        {
            selectedImageFromPicker=editedImage
        
            
        }
        //create  breakpoint here and right click on info->print the desc copy and paste UIImagePickerControllerOriginalImage
        if let originalImage=info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
           selectedImageFromPicker=originalImage
        }
        if let selctedImage = selectedImageFromPicker
        {
        
            profileImageView.image = selctedImage
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*Picker Delegate Methods Ends Here*/
    
    func handleLogInRegister()
    {
        
        if logInRegisterSegmentedControl.selectedSegmentIndex==0
        {
            handleLogIn()
        }
        else
        {
            
            handleRegister()
        }
    }
    func handleLogIn()
    {
        guard let email=emailTextField.text , pass=passwordTextField.text
            else
        {
            print("Plaese enter email and password")
            return
        }
        
        FIRAuth.auth()?.signInWithEmail(email, password: pass, completion: { (user, err) in
            if err != nil{
                print(err)
                return
            }
            self.messagesController?.fetchUserAndSetUpNavBarTitle()
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        
    }
    func handleRegister()
    {
        //guard is used to check for empty text fields
        guard let email=emailTextField.text , pass=passwordTextField.text,name=nameTextField.text
            else
        {
            print("Plaese enter email and password")
            return
        }
        
        FIRAuth.auth()?.createUserWithEmail(email, password: pass, completion: { (user:FIRUser?, error) in
            if error != nil
            {
                print(error)
                return
            }
            
            guard let uid=user?.uid
                else
            {
                return
            }
            //successfully authenticated
            
            /*Upload an Image*/
            let imageName = NSUUID().UUIDString  //gives unique string each time
            let storageRef=FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            
            //image sizes can differe and it can occupy more memory so to compress images
            if let profileImage = self.profileImageView.image , uploadData = UIImageJPEGRepresentation(profileImage, 0.1){
            
            //if let uploadData=UIImageJPEGRepresentation(self.profileImageView.image!, 0.1) //to avoid unwrapping use above
            //{//0.1=10% of original image
            
//if let uploadData=UIImagePNGRepresentation(self.profileImageView.image!){
                storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil{
                        print(error)
                        return
                    
                    }
                    if let profileImageURL = metadata?.downloadURL()?.absoluteString{
                      let values=["name":name,"email":email,"profileImageURL":profileImageURL]
                        self.registerUserIntoDatabaseByUID(uid, values: values)
                    }
                    
                    print(metadata)
                    //to get the url of uploaded image in firebase .create breakpoint here and right click on metadata and print desc and then type po i.e(print object) metadata.downloadURL()
                    
                })
            
            }
            /*Upload an Image*/
            
            
        })
        
    }
    private func registerUserIntoDatabaseByUID(uid:String,values:[String:AnyObject])
    {
        let ref = FIRDatabase.database().reference()  //ref to Firebase db
        
        let userReference = ref.child("users").child(uid)  //this is to save data to firebase in structured format
        
      
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil{
                print(err)
                return
            }
         //  self.messagesController?.fetchUserAndSetUpNavBarTitle()
           // self.messagesController?.navigationItem.title=values["name"] as? String
            let user=User()
            user.setValuesForKeysWithDictionary(values)
            self.messagesController?.setUpNavBarWithUser(user)
            
            self.dismissViewControllerAnimated(true, completion: nil)
            print("successfully saved user to firebase db")
        })
        

    }
    
    func handleSegmentChanged()
    {
        let title=logInRegisterSegmentedControl.titleForSegmentAtIndex(logInRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, forState: .Normal)
        inputContainerHeightConstraint?.constant=logInRegisterSegmentedControl.selectedSegmentIndex == 0 ?100 :150 //if logIn height=100 else 150
        
        //hide name textfield
        nameTextFieldHeightConstraint?.active=false
        nameTextFieldHeightConstraint=nameTextField.heightAnchor.constraintEqualToAnchor(inputsContainer.heightAnchor, multiplier:logInRegisterSegmentedControl.selectedSegmentIndex == 0 ?0 :1/3)
        nameTextFieldHeightConstraint?.active=true
        
        //change height of email password tf
        emailTextFieldHeightConstraint?.active=false
        emailTextFieldHeightConstraint=emailTextField.heightAnchor.constraintEqualToAnchor(inputsContainer.heightAnchor, multiplier:logInRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightConstraint?.active=true
        
        passwordTextFieldHeightConstraint?.active=false
        passwordTextFieldHeightConstraint=passwordTextField.heightAnchor.constraintEqualToAnchor(inputsContainer.heightAnchor, multiplier:logInRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightConstraint?.active=true
        
        
        
    }

}