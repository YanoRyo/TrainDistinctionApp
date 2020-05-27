//
//  TimeLIneViewController.swift
//  TrainDistinctionApp
//
//  Created by 矢野涼 on 2020-05-24.
//  Copyright © 2020 Ryo Yano. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

class TimeLIneViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var refresh = UIRefreshControl()
    var postArray = [PostData]()
    var postImageView = UIImageView()
    var userNameLabel = UILabel()
    var commentLabel = UILabel()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(updata), for: .valueChanged)

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden =  true
        tableView.reloadData()
        fetchPostData()
    }
    
    
    @IBAction func share(_ sender: Any) {
        let shareVC = self.storyboard?.instantiateViewController(identifier: "share") as! ShareViewController
        self.navigationController?.pushViewController(shareVC, animated: true)
    }
    
    
    @objc func updata(){
        tableView.reloadData()
        refresh.endRefreshing()
        fetchPostData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        let contentImageURL = URL(string: self.postArray[indexPath.row].imageURLString)!
        let postImageView = cell.contentView.viewWithTag(1) as! UIImageView
        postImageView.sd_setImage(with: URL(string: self.postArray[indexPath.row].imageURLString)) { (image, error, _, _) in
            if error == nil{
                cell.setNeedsLayout()
            }
        }
        
        userNameLabel = cell.contentView.viewWithTag(2) as! UILabel
        userNameLabel.text = postArray[indexPath.row].userName
        
        commentLabel = cell.contentView.viewWithTag(3) as! UILabel
        commentLabel.text = postArray[indexPath.row].comment
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 534
    }
    
    func fetchPostData(){
        let fecthDataRef = Database.database().reference().child("posts").queryLimited(toLast: 100).queryOrdered(byChild: "postData").observe(.value) { (snapshot) in
            
            self.postArray.removeAll()
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshot{
                    
                    if let postContents = snap.value as? [String:Any]{
                        
                        let postData = PostData()
                        
                        let userName = postContents["userName"] as? String
                        let imageURLString = postContents["imageURLString"] as? String
                        let comment = postContents["comment"] as? String
                        var postDate:CLong?
                        if let postedDate = postContents["postDate"] as? CLong{
                            postDate = postedDate
                        }
                        postData.userName = userName!
                        postData.imageURLString = imageURLString!
                        postData.comment = comment!
                        self.postArray.append(postData)
                    }
                }
                self.tableView.reloadData()
                
            }
        }
    }
    
    
 
}
