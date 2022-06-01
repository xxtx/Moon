//
//  LaunchViewController.swift
//  Moon
//
//  Created by ZY on 2022/5/30.
//

import Foundation
import UIKit

class LaunchViewController:UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .darkContent
    }
    
    private var lauchTime:TimeInterval?
    
    lazy var moonLogo:UIImageView = {
        let img = UIImageView(image: UIImage(named: "lauch_logo"))
        img.frame = CGRect(x: SCREENW/2 - 36, y: SCREENH - BottomBarH - 180, width: 72, height: 100)
        img.contentMode = .scaleToFill
        return img
    }()
    
    lazy var progressBG:UIView = {
        let bg = UIView(frame: CGRect(x: 78, y: SCREENH - BottomBarH - 28, width: SCREENW - 156, height: 4))
        bg.backgroundColor = UIColor.init(rgb: 0xffffff, alpha: 0.3)
        bg.layer.cornerRadius = 2
        bg.clipsToBounds = true
        return bg
    }()
    
    lazy var progressView:UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 4))
        view.backgroundColor = UIColor.init(rgb: 0x1CB5FF)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeLoadingView()
    }
    
    private func makeLoadingView(){
        view.addSubview(moonLogo)
        view.addSubview(progressBG)
        progressBG.addSubview(progressView)
        
        lauchTime = Date().timeIntervalSince1970
        launchInTime()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(arc4random()%5 + 1)) {
            self.launchInTime(1.3)
        }
    }
    
    //加载进度，默认15秒
    func launchInTime(_ timeI:TimeInterval = 15){
        if let startTime = lauchTime{
            progressView.layer.removeAllAnimations()
            progressView.frame.size.width = (SCREENW - 156) * (Date().timeIntervalSince1970 - startTime - 0.5) / 15
        }
        UIView.animate(withDuration: timeI) {
            self.progressView.frame.size.width = SCREENW - 156
        } completion: { isFinish in
            if isFinish{
                MainScene.showMainPage()
            }

        }
    }
}
