//
//  SearchController.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/6/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
import Firebase
class UserSearchController: UICollectionViewController,UISearchBarDelegate,UICollectionViewDelegateFlowLayout
{
    var users:[User] = [User]()
    var filteredUsers = [User]()
    let searchController = UISearchController(searchResultsController: nil)
    let cellID = "cellID"
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupCollectionView()
        setupNavigation()
        fetchUsers()
    }
    
    func setupNavigation()
    {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        self.definesPresentationContext = true
        navigationController?.navigationBar.isTranslucent = false
    }
    
    func setupCollectionView()
    {
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = .white
        collectionView?.register(UserSearchCell.self, forCellWithReuseIdentifier: cellID)
    }
    func fetchUsers() {
    Database.database().reference().child("users").observeSingleEvent(of: .value, with: { (snapShot) in
            guard let dictionaries = snapShot.value as? [String:Any] else {return}
            dictionaries.forEach({ (key,value) in
                let user = User(uid: key, dictionary: value as! [String : Any])
                if key !=  Auth.auth().currentUser?.uid
                {
                    self.users.append(user)
                }
            })
        self.users = self.users.sorted(by: { (u1, u2) -> Bool in
            return u1.username.compare(u2.username) == .orderedAscending
        })
            self.filteredUsers = self.users
            self.collectionView?.reloadData()
        }) { (err) in
            print(err)
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty
        {
            self.filteredUsers = self.users.filter({ (user) -> Bool in
                return user.username.lowercased().contains(searchText.lowercased())
            })
        }
        else
        {
            self.filteredUsers = users
        }
        self.collectionView?.reloadData()
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let user = filteredUsers[indexPath.item]
        let layout = UICollectionViewFlowLayout()
        let userProfileController = UserProfileController(collectionViewLayout: layout)
        userProfileController.uid = user.uid
        navigationController?.pushViewController(userProfileController, animated: true)
        
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredUsers.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! UserSearchCell
        cell.user = filteredUsers[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 66)
    }
}
