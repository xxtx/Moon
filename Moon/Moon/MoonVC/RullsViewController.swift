//
//  RullsViewController.swift
//  Moon
//
//  Created by ZY on 2022/6/2.
//

import Foundation
import UIKit

class RullsViewController:UIViewController{
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .darkContent
    }
    
    var isTerms = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        
        let backBtn = UIButton(frame: CGRect(x: 0, y: StatusBarH + 5, width: 60, height: 40))
        backBtn.setImage(UIImage(named: "icon_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        self.view.addSubview(backBtn)
        
        let textV = UITextView(frame: CGRect(x: 20, y: 64 + StatusBarH, width: SCREENW - 35, height: SCREENH - BottomBarH - StatusBarH - 64))
        textV.backgroundColor = .white
        textV.isEditable = false
        textV.font = .systemFont(ofSize: 16)
        textV.textColor = UIColor(rgb: 0x555555)
        view.addSubview(textV)
        
        let titleLab = UILabel(frame: CGRect(x: 60, y: StatusBarH + 15, width: 150, height: 20))
        titleLab.textColor = UIColor(rgb: 0x333333)
        titleLab.font = .systemFont(ofSize: 19)
        view.addSubview(titleLab)
        
        if isTerms{
            titleLab.text = "Terms of user"
            textV.text =
"""
Test Terms of user
Test Terms of user
Test Terms of user
Test Terms of user
Test Terms of user
Test Terms of user
Test Terms of user
Test Terms of user
Test Terms of user
Test
Test
Test
Test
"""
        }
        else{
            titleLab.text = "private policy"
            textV.text =
"""
Test private policy
Test private policy
Test private policy
Test private policy
Test private policyTest private policy
Test private policy
Test
Test
"""
        }
    }
    
    
    @objc func backClick(){
        self.navigationController?.popViewController(animated: true)
    }
}
