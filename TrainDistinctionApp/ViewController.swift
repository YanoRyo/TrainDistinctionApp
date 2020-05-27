//
//  ViewController.swift
//  TrainDistinctionApp
//
//  Created by 矢野涼 on 2020-05-24.
//  Copyright © 2020 Ryo Yano. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        userNameTextField.delegate = self
        loginButton.layer.cornerRadius = 10
        setUpPhotoLibrary()
        
        if UserDefaults.standard.object(forKey: "userName") != nil{
            userNameTextField.text = UserDefaults.standard.object(forKey: "userName") as! String
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UserDefaults.standard.object(forKey: "userName") != nil{
            performSegue(withIdentifier: "next", sender: nil)

        }
    }
    
    @IBAction func login(_ sender: Any) {
        UserDefaults.standard.set(userNameTextField.text!, forKey: "userName")
        performSegue(withIdentifier: "next", sender: nil)
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        userNameTextField.resignFirstResponder()
    }
        
        
    func setUpPhotoLibrary(){
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status{
            case .authorized: break
            case .denied: break
            case .notDetermined: break
            case .restricted: break
                
            }
        }
    }
    
    
}

