//
//  UserProfileController.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/4/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
import Firebase
class UserProfileController: UICollectionViewController,UICollectionViewDelegateFlowLayout,UserProfileHeaderDelegate {
    var isgrid = true
    func didChangeToListView() {
        isgrid = false
        self.collectionView?.reloadData()
    }
    
    func didChangeToGridView() {
        isgrid = true
        self.collectionView?.reloadData()
    }
    
    let headerID = "headerID"
    let cellID = "cellID"
    let postCellID = "postCellID"
    var user:User?{
        didSet{
            //fetchPosts()
            paginatePosts()
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
        collectionView?.register(HomeFeedCell.self, forCellWithReuseIdentifier: postCellID)
    }
    func fetchUser()
    {
        let userID = uid ?? (Auth.auth().currentUser?.uid) ?? ""
        Database.fetchUser(userID: userID)
        {
            (user) in
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
        header.delegate = self
        return header
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isgrid
        {
            let width = (view.frame.width - 2) / 3
            return CGSize(width: width, height: width)
        }
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 56)
        let dummyCell = HomeFeedCell(frame: frame)
        dummyCell.post = posts[indexPath.item]
        dummyCell.layoutIfNeeded()
        let estimatedsize = dummyCell.systemLayoutSizeFitting(CGSize(width: frame.width, height: 1000))
        let height = estimatedsize.height//max(56, estimatedsize.height)
        let width = (view.frame.width)
        return CGSize(width: width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == self.posts.count - 1
        {
            print("paginate")
        }
        if isgrid
        {   
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ProfilePostPhoto
            cell.post = posts[indexPath.item]
            return cell

        }
        else
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postCellID, for: indexPath) as! HomeFeedCell
            cell.post = posts[indexPath.item]
            return cell
        }
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
    fileprivate func paginatePosts()
    {
        guard let user = user else {return}
        let ref = Database.database().reference().child("posts").child(user.uid)
        let query = ref.queryOrderedByKey().queryLimited(toFirst: 4)
        query.observe(.value, with: { (snap) in
            if let dictionary = snap.value as? [String:Any]
            {
                dictionary.forEach({ (key,value) in
                        let post = Post(user: user, dictionary: value as! [String : Any])
                        self.posts.append(post)
                        self.collectionView?.reloadData()
                })
            }
        }) { (err) in
            print(err)
        }
    }
    fileprivate func fetchPosts()
    {
        guard let currentUserID = user?.uid else {return}
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
