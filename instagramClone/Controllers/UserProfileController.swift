//
//  UserProfileController.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/4/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
import Firebase
class UserProfileController: UICollectionViewController,UICollectionViewDelegateFlowLayout {
    let headerID = "headerID"
    let cellID = "cellID"
    var user:User?{
        didSet{
            fetchPosts()
        }
    }
    var uid:String?
    var posts:[Post] = [Post]()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "gear").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogout))
        fetchUser()
        setupCollectionView()
    }
    func setupCollectionView()
    {
        collectionView?.backgroundColor = .white
        collectionView?.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerID)
        collectionView?.register(ProfilePostPhoto.self, forCellWithReuseIdentifier: cellID)
    }
    func fetchUser()
    {
        let userID = uid ?? (Auth.auth().currentUser?.uid) ?? ""
        Database.fetchUser(userID: userID) { (user) in
            self.user = user
            self.navigationItem.title = user.username
            self.collectionView?.reloadData()
        }
    }
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as! UserProfileHeader
        if let user = user
        {
            header.user = user
        }
        return header
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ProfilePostPhoto
        cell.post = posts[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    @objc func handleLogout()
    {
        let logoutAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Log Out", style: .destructive) { (_) in
            do
            {
                try Auth.auth().signOut()
                self.present(UINavigationController(rootViewController: LoginController()), animated: true, completion: nil)
            }
            catch let error
            {
                print("error logging user out",error)
            }
        }
        let cancelLogoutAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            print("log out cancelled")
        }
        logoutAlert.addAction(logoutAction)
        logoutAlert.addAction(cancelLogoutAction)
        present(logoutAlert, animated: true, completion: nil)
    }
    fileprivate func fetchPosts()
    {
        guard let currentUserID = user?.uid else {return}//
        Database.database().reference().child("posts").child(currentUserID).queryOrdered(byChild: "creationDate").observe(.childAdded) { (snapShot) in
            guard let dictionary = snapShot.value as? [String:Any] else {return}
            guard let user = self.user else {return}
            let post = Post(user:user,dictionary: dictionary)
            self.posts.append(post)
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
}
