//
//  MainPageViewController.swift
//  Moon
//
//  Created by ZY on 2022/5/31.
//

import Foundation
import UIKit
import Lottie

class MainPageViewController:UIViewController{
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .darkContent
    }
    static var shared = BaseNavigationController.init(rootViewController: MainStoryBoard.instantiateViewController(withIdentifier: "MainPageViewController"))
    
    @IBOutlet weak var lightImgv:UIImageView!
    @IBOutlet weak var settingCoverView:UIView!
    @IBOutlet weak var constraintSettingBottom:NSLayoutConstraint!
    
    //链接动画
    lazy var connectingAnimationView: AnimationView = {
        let animationView = AnimationView(name: "connectingAni")
        animationView.frame = lightImgv.bounds
        animationView.loopMode = .loop
        animationView.isHidden = false
        return animationView
    }()
    
    //链接动画
    lazy var disconnectingAnimationView: AnimationView = {
        let animationView = AnimationView(name: "disconnectingAni")
        animationView.frame = lightImgv.bounds
        animationView.loopMode = .loop
        animationView.isHidden = true
        return animationView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(closeSettingView))
        settingCoverView.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lightImgv.addSubview(connectingAnimationView)
        lightImgv.addSubview(disconnectingAnimationView)
    }
    
    @objc func closeSettingView(){
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.settingCoverView.backgroundColor = UIColor(rgb: 0x000000, alpha: 0)
            self.constraintSettingBottom.constant = -470
            self.view.layoutIfNeeded()
        } completion: { isfinish in
            if isfinish{
                self.settingCoverView.isHidden = true
            }
        }
    }
    
    @IBAction func btnSettingClick(){
        settingCoverView.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.settingCoverView.backgroundColor = UIColor(rgb: 0x000000, alpha: 0.6)
            self.constraintSettingBottom.constant = 0
            self.view.layoutIfNeeded()
        } completion: { isfinish in}
    }
    
    @IBAction func btnConnectClick(){
        connectingAnimationView.play()
//        let vc = MainStoryBoard.instantiateViewController(withIdentifier: "ResultPageViewController")
//        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func btnSettingClick(sender:UIButton){
        switch sender.tag {
        case 0:
            break
        case 1:
            break
        case 2:
            break
        case 3:
            break
        default:
            break
        }
    }
}
