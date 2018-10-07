//
//  UserProfileHeader.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/4/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage
class UserProfileHeader: UICollectionViewCell {
    var user:User?{
        didSet{
            guard let user = user else {return}
            profileImageView.sd_setImage(with: URL(string: user.profileImageUrl), completed: nil)
            userNameLabel.text = user.username
            setupEditFollowButton()
        }
    }
    fileprivate func setupEditFollowButton()
    {
        activityIndicator.startAnimating()
        guard let user = user else {return}
        guard let loggedInUser = Auth.auth().currentUser?.uid else {return}
        if user.uid == Auth.auth().currentUser?.uid
        {
           editProfileFollowButton.setTitle("Edit Profile", for: .normal)
        }
        else
        {
      Database.database().reference().child("following").child(loggedInUser).child(user.uid).observe(.value, with:
          {
            (snapshot) in
            
            if let isFollowing = snapshot.value as? Int, isFollowing == 1
            {
                self.editProfileFollowButton.setTitle("Unfollow",for:.normal)
                self.editProfileFollowButton.backgroundColor = .white
                self.editProfileFollowButton.setTitleColor(.black, for: .normal)
            }
            else
            {
                self.editProfileFollowButton.setTitle("Follow", for: .normal)
                self.editProfileFollowButton.setTitleColor(.white, for: .normal)
                self.editProfileFollowButton.backgroundColor = UIColor.rgb(red: 17, green: 154, blue: 237)
                self.editProfileFollowButton.layer.borderWidth = 0.5
                self.editProfileFollowButton.layer.borderColor = UIColor(white: 0.5, alpha: 0.3).cgColor
            }
            }) { (err) in
                
            }
            
        }
        self.activityIndicator.stopAnimating()
    }
    @objc func handleEditProfileOrFollow()
    {
        guard let currentLoggedInuserId = Auth.auth().currentUser?.uid else {return}
        guard let userID = user?.uid else {return}
        if editProfileFollowButton.titleLabel?.text == "Follow"
        {
        let ref = Database.database().reference().child("following").child(currentLoggedInuserId)
        let values = [userID:1]
        ref.updateChildValues(values) { (err, reference) in
            if err != nil
            {
                print(err!)
                return
            }
            print("updated")
            }
        }
        else if editProfileFollowButton.titleLabel?.text == "Unfollow"
        {
            let ref = Database.database().reference().child("following").child(currentLoggedInuserId).child(userID)
            ref.removeValue { (err, ref) in
                if let err = err
                {
                    print(err)
                    return
                }
                print("sucess")
            }
            
        }
    }
    let userNameLabel:UILabel = {
       let label = UILabel()
       label.font = UIFont.boldSystemFont(ofSize: 18)
       return label
    }()
    
    let profileImageView:UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 40
        iv.clipsToBounds = true
        iv.sd_setIndicatorStyle(.gray)
        iv.sd_showActivityIndicatorView()
        return iv
    }()
    
    let gridButton:UIButton = {
       let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
    return button
    }()
    
    let listButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let bookmarkButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    lazy var bottomToolBar:UIStackView = {
       let toolBar = UIStackView(arrangedSubviews: [gridButton,listButton,bookmarkButton])
        toolBar.distribution = .fillEqually
        return toolBar
    }()
    let topSeparator:UIView = {
       let view = UIView()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1)
        return view
    }()
    let bottomSeparator:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.9, alpha: 1)
        return view
    }()
    let postsLabel:UILabel = {
       let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 20)])
        attributedText.append(NSAttributedString(string: "posts", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:UIColor.gray]))
        label.attributedText = attributedText
        label.numberOfLines = -1
        label.textAlignment = .center
        return label
    }()
    
    let followersLabel:UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 20)])
        attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:UIColor.gray]))
        label.attributedText = attributedText
        label.numberOfLines = -1
        label.textAlignment = .center
        return label
    }()
    
    let followingLabel:UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "11\n", attributes: [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 20)])
        attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedStringKey.font:UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:UIColor.gray]))
        
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = -1
        return label
    }()
    
    lazy var statisticsStack:UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [postsLabel,followersLabel,followingLabel])
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var editProfileFollowButton:UIButton = {
       let button = UIButton(type: .system)
       button.setTitleColor(.black, for: .normal)
       button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
       button.layer.borderColor = UIColor.lightGray.cgColor
       button.layer.borderWidth = 0.5
       button.layer.cornerRadius = 4
       button.addTarget(self, action: #selector(handleEditProfileOrFollow), for: .touchUpInside)
       return button
    }()
    
    let activityIndicator:UIActivityIndicatorView = {
       let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
       activity.startAnimating()
       return activity
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileImageView)
        profileImageView.anchorToView(top: topAnchor, left: safeAreaLayoutGuide.leftAnchor, bottom: nil, right: nil, padding: .init(top: 12, left: 12, bottom: 0, right: 0), size: .init(width: 80, height: 80))
        addSubview(bottomToolBar)
        bottomToolBar.anchorToView(top: nil, left: safeAreaLayoutGuide.leftAnchor, bottom: bottomAnchor, right: safeAreaLayoutGuide.rightAnchor, size: .init(width: 0, height: 50))
        addSubview(userNameLabel)
        userNameLabel.anchorToView(top: profileImageView.bottomAnchor, left: profileImageView.leftAnchor, bottom: bottomToolBar.topAnchor, right: rightAnchor, padding: .init(top: 12, left: 0, bottom: 0, right: 0))
        addSubview(statisticsStack)
        statisticsStack.anchorToView(top: topAnchor, left: profileImageView.rightAnchor, right: safeAreaLayoutGuide.rightAnchor, padding: .init(top: 12, left: 12, bottom: 0, right: 12), size: .init(width: 0, height: 50))
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchorToView(top: statisticsStack.bottomAnchor, left: statisticsStack.leftAnchor, right: statisticsStack.rightAnchor, padding: .init(top: 10, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 35))
        addSubview(topSeparator)
        topSeparator.anchorToView(top: bottomToolBar.topAnchor, left: leftAnchor, right: rightAnchor, size: .init(width: 0, height: 0.7))
        addSubview(bottomSeparator)
        bottomSeparator.anchorToView(left: leftAnchor, bottom:bottomToolBar.bottomAnchor, right: rightAnchor,size: .init(width: 0, height: 0.7))
        editProfileFollowButton.addSubview(activityIndicator)
        activityIndicator.anchorToView(centerH: true, centerV: true)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
   
}
