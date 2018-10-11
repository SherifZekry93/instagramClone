//
//  CommentsController.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/9/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
import Firebase
class CommentsController: UICollectionViewController,UICollectionViewDelegateFlowLayout//UIViewController, UITableViewDelegate,UITableViewDataSource
{
    var post:Post?
    let cellID = "cellID"
    var comments = [Comment]()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Comments"
        observeKeyboardNotification()
        setupViews()
        fetchComments()
        setupCollectionView()
        view.backgroundColor = .white
    }
    fileprivate func setupCollectionView()
    {
        collectionView?.register(CommentCell.self, forCellWithReuseIdentifier: cellID)
        collectionView?.backgroundColor = .white
        collectionView?.contentInset = .init(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 50, right: 0)
    }
    fileprivate func observeKeyboardNotification()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! CommentCell
        cell.comment = comments[indexPath.row]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 56)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        let estimatedsize = dummyCell.systemLayoutSizeFitting(CGSize(width: frame.width, height: 1000))
        let height = max(56, estimatedsize.height)
        return CGSize(width: view.frame.width, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    fileprivate func fetchComments()
    {
        guard let id = post?.postId else {return}
        let ref = Database.database().reference().child("comments").child(id)
            
        ref.observe(.childAdded, with: { (snap) in
            if let dictionary = snap.value  as? [String:Any]
            {
                guard let uid = dictionary["uid"] as? String else {return}
                Database.fetchUser(userID: uid, completitionHandler: { (user) in
                    let comment = Comment(user:user,dictionary: dictionary)
                    self.comments.append(comment)
                    self.collectionView?.reloadData()
                    self.scrollToLatestItem()
                })
            }
            
 
        }) { (err) in
            print(err)
        }
    }
    @objc func handleKeyboardNotification(_ notifiction:Notification)
    {
        guard let window = UIApplication.shared.keyWindow else {return}
        if let userinfo = notifiction.userInfo
        {
            let keyboardRect = (userinfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let keyboardHeight = keyboardRect.height
            let isKeyboardShowing = notifiction.name == NSNotification.Name.UIKeyboardWillShow
            UIView.animate(withDuration: 0.5, animations: {
                if isKeyboardShowing
                {
                    self.view.transform = CGAffineTransform(translationX: 0, y:
                        -keyboardHeight + window.safeAreaInsets.bottom)
                }
                else
                {
                    self.view.transform = .identity
                }
            })
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    let containerView:UIView = {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.borderWidth = 0.3
        containerView.layer.borderColor = UIColor.gray.cgColor
        return containerView
    }()
    let textField:LeftPaddedTextField = {
        let textField = LeftPaddedTextField()
        textField.placeholder = "Enter Comment"
        textField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        textField.backgroundColor = .white
        return textField
    }()
    let submitButton:UIButton = {
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        submitButton.isEnabled = false
        submitButton.backgroundColor = .white
        return submitButton
    }()
    let separatorView:UIView = {
       let v = UIView()
        return v
    }()
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        scrollToLatestItem()
    }
    func setupViews()
    {
        view.addSubview(containerView)
        containerView.addSubview(submitButton)
        containerView.addSubview(textField)
        containerView.anchorToView(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor,right:view.rightAnchor, size: .init(width: view.frame.width, height: 50))
        containerView.backgroundColor = .red
        submitButton.anchorToView(top: containerView.topAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, size: .init(width: 60, height: 0))
        
        textField.anchorToView(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: submitButton.leftAnchor)
    }
    @objc func handleSubmit()
    {
        guard let postID = post?.postId else {return}
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        guard let textsComment = textField.text else {return}
        let values = ["text":textsComment,"creationDate":Date().timeIntervalSince1970,"uid":currentUserID] as [String : Any];
        Database.database().reference().child("comments").child(postID).childByAutoId().setValue(values) {
            (err, ref) in
            if let err = err
            {
                print("err",err)
                return
            }
            else {
                print("updated")
                self.scrollToLatestItem()
            }
        }
        textField.text = ""
    }
    func scrollToLatestItem()
    {
        let indexPath = IndexPath(item: self.comments.count - 1, section: 0)
        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    @objc func handleTextChange()
    {
        guard let count = textField.text?.count else {return}
        if count > 0
        {
            submitButton.isEnabled = true
        }
        else
        {
            submitButton.isEnabled = false
        }
    }
}
