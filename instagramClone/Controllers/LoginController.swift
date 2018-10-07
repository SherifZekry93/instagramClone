//
//  LoginController.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/4/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
import Firebase
class LoginController: UIViewController {
    
    let signUpButton:UIButton = {
       let button = UIButton(type: .system)
        let attributedText = NSMutableAttributedString(string: "Don't have an account? ", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 16),NSAttributedStringKey.foregroundColor: UIColor.lightGray])
        attributedText.append(NSAttributedString(string: "Sign Up.", attributes: [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 16),NSAttributedStringKey.foregroundColor: UIColor.blue]))
        button.setAttributedTitle(attributedText, for: .normal)
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
       return button
    }()
    
    let logoPhoto:UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "Instagram_logo_white")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    let logoHolder:UIView = {
        let holder = UIView()
        holder.backgroundColor =  UIColor.rgb(red: 17, green: 154, blue: 237)
        return holder
    }()
    
    let loginButton:UIButton = {
        let button = UIButton(type: .system)
        button.isEnabled = false
        button.setTitle("Login", for: .normal)
        button.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    let emailTextField: LeftPaddedTextField = {
        let tf = LeftPaddedTextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.04)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    let passwordTextField: LeftPaddedTextField = {
        let tf = LeftPaddedTextField()
        tf.placeholder = "Password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.04)
        tf.addTarget(self, action: #selector(handleTextInputChange), for: .editingChanged)
        return tf
    }()
    
    lazy var fieldsStackView:UIStackView = {
        let stack = UIStackView(arrangedSubviews: [emailTextField,passwordTextField,loginButton])
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.axis = .vertical
        return stack
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.isNavigationBarHidden = true
        setupViews()
    }
    func setupViews()
    {
        guard let heightOfSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.top else {return}
        view.addSubview(signUpButton)
        signUpButton.anchorToView(top: nil, left:view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, size: .init(width:0,height:50))
        view.addSubview(logoHolder)
        logoHolder.anchorToView(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, padding: .zero, size: .init(width: 0, height: 150))
        logoHolder.addSubview(logoPhoto)
        
        logoPhoto.translatesAutoresizingMaskIntoConstraints = false
        logoPhoto.centerXAnchor.constraint(equalTo: logoHolder.centerXAnchor, constant: 0).isActive = true
        
        logoPhoto.heightAnchor.constraint(equalToConstant: 50).isActive = true
        if heightOfSafeArea != 0
        {
        logoPhoto.centerYAnchor.constraint(equalTo: logoHolder.centerYAnchor, constant: heightOfSafeArea - 25).isActive = true
        }
        else
        {
              logoPhoto.centerYAnchor.constraint(equalTo: logoHolder.centerYAnchor, constant: 0).isActive = true
        }
        view.addSubview(fieldsStackView)
        fieldsStackView.anchorToView(top: logoHolder.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, padding: .init(top: 14, left: 24, bottom: 0, right: 24), size: .init(width: 0, height: 140))
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    @objc func handleSignUp()
    {
    navigationController?.pushViewController(SignUpViewController(), animated: true)
    }
    @objc func handleTextInputChange()
    {
        let isFormValid =  emailTextField.text?.count ?? 0 > 0
            && passwordTextField.text?.count ?? 0 > 5 &&
             isValidEmail(testStr: emailTextField.text ?? "")
        if isFormValid
        {
            loginButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
            loginButton.isEnabled = true
        }
        else
        {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.rgb(red: 149, green: 204, blue: 244)
        }
    }
    func isValidEmail(testStr:String) -> Bool
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    @objc func handleLogin()
    {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (_, err) in
            if err != nil
            {
                print("error logging in",err!)
                return
            }
            guard let root = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController else {return}
            root.setupControllers()
            self.dismiss(animated: true, completion: nil)
        }
    }
}
