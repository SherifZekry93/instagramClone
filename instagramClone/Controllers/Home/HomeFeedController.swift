//
//  HomeFeedController.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/6/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
import Firebase
class HomeFeedController: UICollectionViewController,UICollectionViewDelegateFlowLayout,HomePostCellDelegate{
    func didLike(for cell: HomeFeedCell) {
        
        guard let indexPath = collectionView?.indexPath(for: cell) else {return}
        
        let post = self.posts[indexPath.item]
        
        guard let postID = post.postId else {return}
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        let values = [uid:post.hasLiked ? 0 : 1];
   Database.database().reference().child("likes").child(postID).updateChildValues(values) { (err, ref) in
            if let err = err
            {
                print(err)
                return
            }
        self.posts[indexPath.item].hasLiked = !self.posts[indexPath.item].hasLiked
        self.collectionView?.reloadData()
        }
    }
    
    func didTabComments(post: Post) {
        let layout = UICollectionViewFlowLayout();
        let commentsController = CommentsController(collectionViewLayout: layout)
        commentsController.post = post;
    navigationController?.pushViewController(commentsController, animated: true)
    }
    let cellID = "cellID"
    var posts:[Post] = [Post]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = NSNotification.Name(rawValue: "FeedUpdated")
        NotificationCenter.default.addObserver(self, selector: #selector(handleUpdateFeed), name: name, object: nil)
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        setupCollectionViews()
        setupNavBar()
        handleRefresh()
    }
    @objc func handleRefresh()
    {
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "camera3").withRenderingMode(.alwaysOriginal), style: .plain, target:self , action: #selector(handleCamera))
    }
    @objc func handleCamera()
    {
        let controller = CameraController()
        present(controller, animated: true, completion: nil)
    }
    fileprivate func fetchPosts()
    {
        self.posts = [Post]()
        guard let userID = Auth.auth().currentUser?.uid else {return};
        Database.fetchUser(userID: userID) { (user) in
            self.fetchPostsWithUser(user: user)
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    fileprivate func fetchPostsWithUser(user:User)
    {
        guard let auth = Auth.auth().currentUser?.uid else {return}; Database.database().reference().child("posts").child(user.uid).observe(.value) { (snapShot) in
            guard let dictionaries = snapShot.value as? [String:Any] else {return}
            dictionaries.forEach({ (key,value) in
                if let hasValue = value as? [String:Any]
                {
                    Database.database().reference().child("likes").child(key).child(auth).observe(.value, with: { (snap) in
                        var post = Post(user: user, dictionary: hasValue)
                        post.postId = key
                      
                        if let liked = snap.value as? Int , liked == 1
                        {
                            post.hasLiked = true
                        }
                        else
                        {
                            post.hasLiked = false
                        }
                        self.posts.append(post)

                    })
                }
            })
            DispatchQueue.main.async {
                self.posts.sort(by: { (p1, p2) -> Bool in
                    return p1.creationDate.compare(p2.creationDate) == .orderedDescending
                })
                self.collectionView?.reloadData()
                self.collectionView?.refreshControl?.endRefreshing()
            }
        }
    }
    @objc func handleUpdateFeed()
    {
        handleRefresh()
    }
    fileprivate func fetchFollowings()
    {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child("following").child(currentUserID).observeSingleEvent(of: .value) { (snapshot) in
            
            if let dictionary = snapshot.value as? [String:Any]
            {
                dictionary.forEach({ (key,value) in
                    Database.fetchUser(userID: key, completitionHandler: { (user) in
                        self.fetchPostsWithUser(user: user)
                    })
                })
            }
            
        }
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! HomeFeedCell
        if posts.count > 0 //= posts[indexPath.item]
        {
            cell.post = posts[indexPath.item]
        }
        cell.delegate = self
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
   
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 56)
        let dummyCell = HomeFeedCell(frame: frame)
        dummyCell.post = posts[indexPath.item]
        dummyCell.layoutIfNeeded()
        let estimatedsize = dummyCell.systemLayoutSizeFitting(CGSize(width: frame.width, height: 1000))
        let height = max(56, estimatedsize.height)
        return CGSize(width: self.view.frame.width, height: height)
    }
}

