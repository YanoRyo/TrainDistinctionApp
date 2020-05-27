//
//  ShareViewController.swift
//  TrainDistinctionApp
//
//  Created by 矢野涼 on 2020-05-24.
//  Copyright © 2020 Ryo Yano. All rights reserved.
//

import UIKit
import Firebase
import VisualRecognition
import EMAlertController

class ShareViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate {

    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var contentImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    
    var userName = String()
    var comment = String()
    var imageURLString = String()
    
    var visualRecognition = VisualRecognition(version: "2020-05-25", apiKey: "eahLPi80a9cunhY4RJ3KJrOU24LxquvI4XLpoEYCoPWW")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        shareButton.layer.cornerRadius = 10
        commentTextView.delegate = self
        
        if UserDefaults.standard.object(forKey: "userName") != nil{
            userName = UserDefaults.standard.object(forKey: "userName") as! String
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        commentTextView.resignFirstResponder()
    }
    
    @IBAction func share(_ sender: Any) {
        //watsonに画像のURLを提供
        if contentImageView.image == nil{
            DispatchQueue.main.async {
                self.emptyAlert()
            }
            return
        }
        let timeLineDB = Database.database().reference().child("posts").childByAutoId()
        let storage = Storage.storage().reference(forURL: "gs://traindestinction.appspot.com")
        let key = timeLineDB.child("Contents").childByAutoId().key
        let imageRef = storage.child("Contents").child("\(String(describing: key!)).jpg")
        var contentImageData:Data = Data()
        if contentImageView.image != nil{
            contentImageData = (contentImageView.image?.jpegData(compressionQuality: 0.01))!
        }
        let uploadTask = imageRef.putData(contentImageData, metadata: nil){
            (metaData,error) in
            if error != nil{
                return
            }
            imageRef.downloadURL { (url, error) in
                if url! != nil{
                    let resultURL = url?.absoluteString
                    self.visualRecognition.classify(url:resultURL) { response,  error in
                        if let error = error {
                            print(error)
                        }
                        let str : String = (response?.result?.images[0].classifiers[0].classes[0].typeHierarchy)!

                        if str.contains("train") == false{
                            
                            DispatchQueue.main.async {
                                
                                self.checkAlert()
                            }
                            
                        }else{
                            DispatchQueue.main.async {
                                
                                if (self.userName != nil && url?.absoluteString != nil && self.commentTextView.text.isEmpty != true){
                                    
                                    let timeLineInfo = ["userName":self.userName as Any,"imageURLString":url?.absoluteString as Any,"comment":self.commentTextView.text as Any,"postDate":ServerValue.timestamp()] as [String:Any]
                                    timeLineDB.updateChildValues(timeLineInfo)
                                    self.navigationController?.popViewController(animated: true)
                                }else{
                                    DispatchQueue.main.async {
                                        self.emptyAlert()
                                    }
                                }
                            }
                        }
                        
                    }
                    
                }
            }
        }
        uploadTask.resume()
        
    }
    
    func checkAlert(){
        
        let alert = EMAlertController(icon: UIImage(named: "trainImage2"), title: "どうやら電車ではないようです！", message: "電車の画像のみ投稿できます！")
        let action1 = EMAlertAction(title: "OK", style: .normal) {
        }
        
        alert.addAction(action1)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func emptyAlert(){
        
        let alert = EMAlertController(icon: UIImage(named: "trainImage2"), title: "何かが入力されていません！", message: "入力してください。")
        let action1 = EMAlertAction(title: "OK", style: .normal) {
        }
        alert.addAction(action1)
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func openCamera(_ sender: Any) {
        let sourceType:UIImagePickerController.SourceType = UIImagePickerController.SourceType.camera
        // カメラが利用可能かチェック
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = true
            cameraPicker.showsCameraControls = true
            self.present(cameraPicker, animated: true, completion: nil)
            
        }else{
            
            print("エラー")
        }
        
    }
    
    @IBAction func openAlubum(_ sender: Any) {
        let sourceType:UIImagePickerController.SourceType = UIImagePickerController.SourceType.photoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            // インスタンスの作成
            let cameraPicker = UIImagePickerController()
            cameraPicker.sourceType = sourceType
            cameraPicker.delegate = self
            cameraPicker.allowsEditing = true
            self.present(cameraPicker, animated: true, completion: nil)
            
        }
        else{
            print("エラー")
            
        }
    }
    
    //　撮影が完了時した時に呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        if let pickedImage = info[.editedImage] as? UIImage
        {
            contentImageView.image = pickedImage
            //閉じる処理
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    
    // 撮影がキャンセルされた時に呼ばれる
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
