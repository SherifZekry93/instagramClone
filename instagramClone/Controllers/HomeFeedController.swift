//
//  HomeFeedController.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/6/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
import Firebase
class HomeFeedController: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    let cellID = "cellID"
    var posts:[Post] = [Post]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViews()
        setupNavBar()
        fetchPosts()
        fetchFollowings()
    }
    func setupCollectionViews()
    {
        collectionView?.register(HomeFeedCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.backgroundColor = .white
    }
    func setupNavBar()
    {
        let imageLogo = UIImageView()
        imageLogo.image = #imageLiteral(resourceName: "logo2")
        imageLogo.contentMode = .scaleAspectFit
        navigationItem.titleView = imageLogo
    }
    
    fileprivate func fetchPosts()
    {
        guard let userID = Auth.auth().currentUser?.uid else {return};
        Database.fetchUser(userID: userID) { (user) in
            self.fetchPostsWithUser(user: user)
        }
    }
    fileprivate func fetchPostsWithUser(user:User)
    {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return};
        Database.database().reference().child("posts").child(currentUserID).observe(.value) { (snapShot) in
            guard let dictionaries = snapShot.value as? [String:Any] else {return}
            dictionaries.forEach({ (key,value) in
                
                let post = Post(user: user, dictionary: value as! [String : Any])
                self.posts.append(post)
            })
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
            
        }
    }
    fileprivate func fetchFollowings()
    {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("following").child(currentUserID).observeSingleEvent(of: .childAdded) { (snap) in
            if let dictionary = snap.value as? [String:Any]
            {
                dictionary.forEach({ (key,value) in
                    Database.fetchUser(userID: key) { (user) in
                        self.fetchPostsWithUser(user: user)
                    }
                })
                
            }
        }
    }
    /*fileprivate func fetchPostsWithUser(user:User)
    {
        Database.database().reference().child("posts").child(user.uid).observe(.value) { (snapShot) in
            guard let dictionaries = snapShot.value as? [String:Any] else {return}
            dictionaries.forEach({ (key,value) in
                
                let post = Post(user: user, dictionary: value as! [String : Any])
                self.posts.append(post)
            })
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
            
        }
    }*/
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! HomeFeedCell
        cell.post = posts[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            var height:CGFloat = 40 + 8 + 8
            height += self.view.frame.width
            height += 50
            height += 80 // text height
        
        return CGSize(width: self.view.frame.width, height: height)
    }
}

