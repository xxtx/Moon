//
//  ResultPageViewController.swift
//  Moon
//
//  Created by ZY on 2022/6/1.
//

import Foundation
import UIKit

class ResultPageViewController:UIViewController{
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .darkContent
    }
    
    var isSuccess = true
    var clickHandle:(() -> Void)?
    
    @IBOutlet weak var stateImg:UIImageView!
    @IBOutlet weak var stateLab:UILabel!
    @IBOutlet weak var descLab:UILabel!
    @IBOutlet weak var connectBtn:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        
        if isSuccess {
            stateImg.image = UIImage(named: "connectedLight")
            stateLab.text = "Connected Successful!"
            descLab.text = "Real-time internet speed monitoring is enabled"
            connectBtn.setTitle("Select new servers", for: .normal)
        }
        else{
            stateImg.image = UIImage(named: "disconnectedLight")
            stateLab.text = "Disconnected"
            descLab.text = ""
            connectBtn.setTitle("Connect again", for: .normal)
        }
    }
    
    @IBAction func backClick(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func connectClick(){
        self.navigationController?.popViewController(animated: false)
        self.clickHandle?()
    }
}
