//
//  MainPageViewController+AD.swift
//  Moon
//
//  Created by ZY on 2022/6/10.
//

import Foundation
import GoogleMobileAds

extension MainPageViewController: GADFullScreenContentDelegate, GADNativeAdDelegate{
    
    //展示广告是否需要跳转结果页
    func showConnectAD(_ toResult:Bool = false){
        self.isToResultVC = toResult
        if let ad = GadInterstitialLoader.shared.arrConnectAdLoaded.first, self.viewIfLoaded?.window != nil, isInForeGround, GoogleADManager.shared.isUserCanShowAd(){
            self.currConnectAD = ad
            do {
                try self.currConnectAD?.adloaded.canPresent(fromRootViewController: self)
                self.currConnectAD?.adloaded.fullScreenContentDelegate = self
                self.currConnectAD?.adloaded.present(fromRootViewController: self)
            } catch let e {
                ShowLog("[AD] \(InterstitialAdType.connectAD.rawValue) 广告展示失败 \(e.localizedDescription)")
                self.showResultVC()
            }
            if GadInterstitialLoader.shared.arrConnectAdLoaded.count > 0{
                GadInterstitialLoader.shared.arrConnectAdLoaded.removeFirst()
            }
        }
        else{
            self.showResultVC()
        }
    }
    
    func showBackHomeAD(){
        if let ad = GadInterstitialLoader.shared.arrBackAdLoaded.first, self.viewIfLoaded?.window != nil, isInForeGround, GoogleADManager.shared.isUserCanShowAd(){
            self.currBackAD = ad
            do {
                try self.currBackAD?.adloaded.canPresent(fromRootViewController: self)
                self.currBackAD?.adloaded.fullScreenContentDelegate = self
                self.currBackAD?.adloaded.present(fromRootViewController: self)
            } catch let e {
                ShowLog("[AD] \(InterstitialAdType.backHomeAD.rawValue) 广告展示失败 \(e.localizedDescription)")
            }
            if GadInterstitialLoader.shared.arrBackAdLoaded.count > 0{
                GadInterstitialLoader.shared.arrBackAdLoaded.removeFirst()
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
        }
    }
    
    func adDidRecordImpression(_ ad: GADFullScreenPresentingAd) {
        adUserClickCount = 0
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if ad.isEqual(currConnectAD?.adloaded){
            self.showResultVC()
        }
    }
    

    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        if ad.isEqual(currConnectAD?.adloaded){
            ShowLog("[AD] \(InterstitialAdType.connectAD.rawValue) 广告展示 ID:\(self.currConnectAD?.adIdentifier ?? "null"), level: \(self.currConnectAD?.adOrder ?? 0)")
        }
        else{
            ShowLog("[AD] \(InterstitialAdType.backHomeAD.rawValue) 广告展示 ID:\(self.currBackAD?.adIdentifier ?? "null"), level: \(self.currBackAD?.adOrder ?? 0)")
        }
        GoogleADManager.shared.addUserShowCount()
    }
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        if ad.isEqual(currConnectAD?.adloaded){
            ShowLog("[AD] \(InterstitialAdType.connectAD.rawValue) 广告展示失败")
        }
        else{
            ShowLog("[AD] \(InterstitialAdType.backHomeAD.rawValue) 广告展示失败")
        }
    }
    
    
    func requstHomeAD(){
        if (mainhomeAdShowTime != nil && Date().timeIntervalSince1970 - mainhomeAdShowTime! < 9.9) || self.viewIfLoaded?.window == nil {
            return
        }
        GadNativeLoader.shared.requesAdOf(.homeAD) {[weak self] isSuccess in
            if isSuccess{
                if let admob = GadNativeLoader.shared.arrMainAdLoaded.first{
                    self?.homeAdView.isHidden = false
                    self?.homeAdView.nativeAd = admob.adloaded
                    self?.homeAdView.nativeAd!.delegate = self
                    self?.mainhomeAdShowTime = Date().timeIntervalSince1970
                    ShowLog("[AD] \(NativeAdType.homeAD) 广告展示 ID:\(admob.adIdentifier ?? ""), level:\(admob.adIdentifier ?? "")")
                    GadNativeLoader.shared.arrMainAdLoaded.removeFirst()
                    GoogleADManager.shared.addUserShowCount()
                }
            }
        }
    }

    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        GoogleADManager.shared.addUserClickCount()
    }
}
