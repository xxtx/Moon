//
//  LaunchViewController.swift
//  Moon
//
//  Created by ZY on 2022/5/30.
//

import Foundation
import UIKit
import GoogleMobileAds

class LaunchViewController:UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .darkContent
    }
    
    private var lauchTime:TimeInterval? //记录已经展示的loading时长
    private var isInhome = false        //是否已经进入主页
    private var isShowAd = false        //是否正在展示广告
    private var currInterAD:GadInterstitialLoadedModel?  //正在展示的广告
    private var adUserClickCount = 0
    
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
        
        GadInterstitialLoader.shared.requesAdOf(.connectAD, completeHandler: nil)
        GadNativeLoader.shared.requesAdOf(.homeAD, completeHandler: nil)
        GadNativeLoader.shared.requesAdOf(.resultAD, completeHandler: nil)
    }
    
    private func makeLoadingView(){
        view.addSubview(moonLogo)
        view.addSubview(progressBG)
        progressBG.addSubview(progressView)
        
        lauchTime = Date().timeIntervalSince1970
        launchInTime()
        
        GadInterstitialLoader.shared.requesAdOf(.loadingAD, completeHandler: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.3) {
            GadInterstitialLoader.shared.checkInterstitialAdOf(.loadingAD) { isSuccess in
                self.launchInTime(1.1)
                if isSuccess{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.showLoadingAD()
                    }
                }
            }
        }
    }
    
    //加载进度，默认15秒
    private func launchInTime(_ timeI:TimeInterval = 15){
        if let startTime = lauchTime{
            progressView.layer.removeAllAnimations()
            progressView.frame.size.width = (SCREENW - 156) * (Date().timeIntervalSince1970 - startTime - 0.5) / 15
        }
        UIView.animate(withDuration: timeI) {
            self.progressView.frame.size.width = SCREENW - 156
        } completion: { isFinish in
            if isFinish{
                self.showHomePage()
            }
        }
    }
    
    private func showHomePage(){
        if !isShowAd, !isInhome{
            isInhome = true
            MainScene.showMainPage()
        }
    }
}

extension LaunchViewController:GADFullScreenContentDelegate{
    
    private func showLoadingAD(){
        if let ad = GadInterstitialLoader.shared.arrLoadingAdLoaded.first, !isInhome, self.viewIfLoaded?.window != nil, isInForeGround, GoogleADManager.shared.isUserCanShowAd(){
            self.currInterAD = ad
            self.isShowAd = true
            do {
                try self.currInterAD?.adloaded.canPresent(fromRootViewController: self)
                self.currInterAD?.adloaded.fullScreenContentDelegate = self
                self.currInterAD?.adloaded.present(fromRootViewController: self)
            } catch let e {
                ShowLog("[AD] \(InterstitialAdType.loadingAD.rawValue) 广告展示失败 \(e.localizedDescription)")
                self.isShowAd = false
                self.showHomePage()
            }
            if GadInterstitialLoader.shared.arrLoadingAdLoaded.count > 0{
                GadInterstitialLoader.shared.arrLoadingAdLoaded.removeFirst()
            }
        }
    }
    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        GoogleADManager.shared.addUserClickCount()
        adUserClickCount += 1
        if adUserClickCount >= 2 {
            UserDefaults.standard.setValue(Date().timeIntervalSince1970, forKey: KeyOfUserMalignant)
            if let vc = self.presentedViewController {
                vc.dismiss(animated: false, completion: nil)
            }
            self.isShowAd = false
            self.showHomePage()
        }
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        adUserClickCount = 0
    }

    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        ShowLog("[AD] \(InterstitialAdType.loadingAD.rawValue) 广告展示 ID:\(self.currInterAD?.adIdentifier ?? "null"), level: \(self.currInterAD?.adOrder ?? 0)")
        GoogleADManager.shared.addUserShowCount()
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        self.isShowAd = false
        self.showHomePage()
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        ShowLog("[AD] \(InterstitialAdType.loadingAD.rawValue) 广告展示失败")
        self.isShowAd = false
        self.showHomePage()
    }
}
