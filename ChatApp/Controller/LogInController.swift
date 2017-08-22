//
//  LogInController.swift
//  FirebaseWithChatApp
//
//  Created by Pushpanjali Pawar on 7/28/16.
//  Copyright © 2016 Pushpanjali Pawar. All rights reserved.
//

import UIKit
import Firebase
class LogInController: UIViewController {
    
    
    var messagesController:MessagesController?

    
    let inputsContainer:UIView = {
    /*view for uname password*/
        let view=UIView()
        view.backgroundColor=UIColor.whiteColor()
        view.translatesAutoresizingMaskIntoConstraints=false
        view.layer.cornerRadius=5
        view.layer.masksToBounds=true
        return view
        /*Ends here*/
    }()
    
    lazy var  loginRegisterButton:UIButton = {
        let button = UIButton(type: .System)
        button.backgroundColor = UIColor(r:80,g:101,b:161)
        button.setTitle("Register", forState: .Normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(16)
        button.addTarget(self, action: #selector(handleLogInRegister), forControlEvents: .TouchUpInside)
        return button
    }()
    
    //here lazy var is written to enable button target as self
    
    /*Text Fields*/
    let nameTextField:UITextField={
        let tf=UITextField()
        tf.placeholder="Name"
        tf.translatesAutoresizingMaskIntoConstraints=false
        return tf
        
    }()
    let nameSeparatorView:UIView = {
        let view=UIView()
        view.backgroundColor=UIColor(r:220,g:220,b:220)
        view.translatesAutoresizingMaskIntoConstraints=false
        return view
    }()
    
    let emailTextField:UITextField={
        let tf=UITextField()
        tf.placeholder="Email"
        tf.translatesAutoresizingMaskIntoConstraints=false
        return tf
        
    }()
    let emailSeparatorView:UIView = {
        
        let view=UIView()
        view.backgroundColor=UIColor(r:220,g:220,b:220)
        view.translatesAutoresizingMaskIntoConstraints=false
        return view
    }()
    
    let passwordTextField:UITextField={
        let tf=UITextField()
        tf.placeholder="Password"
        tf.translatesAutoresizingMaskIntoConstraints=false
        tf.secureTextEntry=true
        return tf
        
    }()
    

    /*Text Field ends here*/
    
    /*Profile Image View*/
    lazy var profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"gameofthrones_splash")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .ScaleAspectFill
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(handleSelectProfImage) ))
        imageView.userInteractionEnabled=true
        return imageView
    }()
    
   
    /*Profile Image View Ends Here*/
    /*Log In Register segmented control*/
   lazy var logInRegisterSegmentedControl:UISegmentedControl={
    
        let sc = UISegmentedControl(items:["LogIn","Register"])
        sc.tintColor=UIColor.whiteColor()
        sc.selectedSegmentIndex=1
        sc.addTarget(self, action: #selector(handleSegmentChanged), forControlEvents: .ValueChanged)
        sc.translatesAutoresizingMaskIntoConstraints=false
        return sc
    }()
    /*Ends Here*/
    
    override func viewDidLoad() {
        super.viewDidLoad()

      //  view.backgroundColor=UIColor(red: 61/255.0, green: 91/255.0, blue: 151/255.0, alpha: 1)  //to avoid writing 255 again and again create extension
        view.backgroundColor=UIColor(r: 61,g: 91,b: 151)
        self.view.addSubview(inputsContainer)
        self.view.addSubview(loginRegisterButton)
        self.view.addSubview(profileImageView)
        self.view.addSubview(logInRegisterSegmentedControl)
        
        setUpInputsContainer()
        setUpLoginRegisterButton()
        setUpProfileImageView()
        setUpLogInSegmentedControl()
        
}
    
    //to get the white status bar
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    //ends Here
    
    //Set up inputsContainer
    
    //create height constraint for inputsContainer
    var inputContainerHeightConstraint:NSLayoutConstraint?
    //to hide name textfield when login clicked
    var nameTextFieldHeightConstraint:NSLayoutConstraint?
    //to change height of email and password tf
    var emailTextFieldHeightConstraint:NSLayoutConstraint?
    var passwordTextFieldHeightConstraint:NSLayoutConstraint?
    
    
    func setUpInputsContainer()
    {
    
        /*Constraints only available for IOS9 and later*/
        inputsContainer.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active=true    //horizontally center
        
        inputsContainer.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active=true    //vertically in container
        inputsContainer.widthAnchor.constraintEqualToAnchor(view.widthAnchor, constant: -24).active=true
        
        inputContainerHeightConstraint=inputsContainer.heightAnchor.constraintEqualToConstant(150) //this is to shrink height when log IN clicked
        inputContainerHeightConstraint?.active=true
        
        inputsContainer.addSubview(nameTextField)
        inputsContainer.addSubview(nameSeparatorView)
        
        inputsContainer.addSubview(emailTextField)
        inputsContainer.addSubview(emailSeparatorView)
        
        inputsContainer.addSubview(passwordTextField)
        /*constraint for text field*/
        nameTextField.leftAnchor.constraintEqualToAnchor(inputsContainer.leftAnchor, constant: 12).active=true //x pos
        nameTextField.topAnchor.constraintEqualToAnchor(inputsContainer.topAnchor).active=true  //y pos
        nameTextField.widthAnchor.constraintEqualToAnchor(inputsContainer.widthAnchor).active=true
        
        nameTextFieldHeightConstraint=nameTextField.heightAnchor.constraintEqualToAnchor(inputsContainer.heightAnchor, multiplier: 1/3)
        nameTextFieldHeightConstraint?.active=true
        //each text field will have height=1/3 of inputContainer height
        
        emailTextField.leftAnchor.constraintEqualToAnchor(inputsContainer.leftAnchor, constant: 12).active=true //x pos
        emailTextField.topAnchor.constraintEqualToAnchor(nameTextField.bottomAnchor).active=true   //y pos
        emailTextField.widthAnchor.constraintEqualToAnchor(inputsContainer.widthAnchor).active=true
        
        emailTextFieldHeightConstraint=emailTextField.heightAnchor.constraintEqualToAnchor(inputsContainer.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightConstraint?.active=true
        
        passwordTextField.leftAnchor.constraintEqualToAnchor(inputsContainer.leftAnchor, constant: 12).active=true //x pos
        passwordTextField.topAnchor.constraintEqualToAnchor(emailTextField.bottomAnchor).active=true   //y pos
        passwordTextField.widthAnchor.constraintEqualToAnchor(inputsContainer.widthAnchor).active=true
        
        passwordTextFieldHeightConstraint=passwordTextField.heightAnchor.constraintEqualToAnchor(inputsContainer.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightConstraint?.active=true


        /*Ends Here*/
        
        
        /*constraints for the separator*/
        nameSeparatorView.leftAnchor.constraintEqualToAnchor(inputsContainer.leftAnchor).active=true //x pos
        nameSeparatorView.topAnchor.constraintEqualToAnchor(nameTextField.bottomAnchor).active=true
        nameSeparatorView.widthAnchor.constraintEqualToAnchor(inputsContainer.widthAnchor).active=true
        nameSeparatorView.heightAnchor.constraintEqualToConstant(1).active=true
        
        emailSeparatorView.leftAnchor.constraintEqualToAnchor(inputsContainer.leftAnchor).active=true //x pos
        emailSeparatorView.topAnchor.constraintEqualToAnchor(emailTextField.bottomAnchor).active=true
        emailSeparatorView.widthAnchor.constraintEqualToAnchor(inputsContainer.widthAnchor).active=true
        emailSeparatorView.heightAnchor.constraintEqualToConstant(1).active=true
        
        /*Ends Here*/
        

    }
    
    //set up log in button
    
    func setUpLoginRegisterButton()
    {
        /*Constraints for button*/
        loginRegisterButton.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active=true
        loginRegisterButton.topAnchor.constraintEqualToAnchor(inputsContainer.bottomAnchor, constant: 12).active=true //button's top=inputscontainer's bottom+12
        loginRegisterButton.widthAnchor.constraintEqualToAnchor(inputsContainer.widthAnchor).active=true
        loginRegisterButton.heightAnchor.constraintEqualToConstant(50).active=true
        
    
    }
    //Ends Here
    
    /*Set up Profile Image View*/
    func setUpProfileImageView()
    {
        
     profileImageView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active=true
     profileImageView.bottomAnchor.constraintEqualToAnchor(logInRegisterSegmentedControl.topAnchor, constant: -12).active=true
    // profileImageView.topAnchor.constraintEqualToAnchor(self.topLayoutGuide.bottomAnchor, constant: 20)
     profileImageView.widthAnchor.constraintEqualToConstant(150).active=true
     profileImageView.heightAnchor.constraintEqualToConstant(100).active=true
    }
    
    /*Ends Here*/
    
    /*Set Up LogIn Segmented Control*/
    func setUpLogInSegmentedControl()
    {
    
        logInRegisterSegmentedControl.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active=true
        logInRegisterSegmentedControl.bottomAnchor.constraintEqualToAnchor(inputsContainer.topAnchor, constant: -12).active=true
        logInRegisterSegmentedControl.widthAnchor.constraintEqualToAnchor(inputsContainer.widthAnchor,multiplier: 0.5).active=true
        logInRegisterSegmentedControl.heightAnchor.constraintEqualToConstant(36).active=true
    }
    /*Ends Here*/
          
}
