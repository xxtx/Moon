//
//  GadInterstitialLoader.swift
//  Moon
//
//  Created by ZY on 2022/6/8.
//


import Foundation
import GoogleMobileAds

class GadInterstitialLoader: NSObject{
    static let shared = GadInterstitialLoader.init()
    
    // loading waterfall相关
    private var isLoadingAdRequesting = false
    var arrLoadingAdLoaded = [GadInterstitialLoadedModel]()
    
    // connect waterfall相关
    private var isConnectAdRequesting = false
    var arrConnectAdLoaded = [GadInterstitialLoadedModel]()
    
    // backHome waterfall相关
    private var isbackAdRequesting = false
    var arrBackAdLoaded = [GadInterstitialLoadedModel]()
    
    private override init() {
        super.init()
        Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(removeAdCashOutTime), userInfo: nil, repeats: true)
    }
    
    @objc func removeAdCashOutTime() {
        ShowLog("[AD] 开始检测缓存地广告是否超时未使用 loading:\(arrLoadingAdLoaded.count) connect:\(arrConnectAdLoaded.count) backHome:\(arrBackAdLoaded.count)")
        let now = Date().timeIntervalSince1970
        arrLoadingAdLoaded = arrLoadingAdLoaded.filter({ admobad in
            return now - TimeInterval(admobad.creatTime) <= 2999
        })
        arrConnectAdLoaded = arrConnectAdLoaded.filter({ admobad in
            return now - TimeInterval(admobad.creatTime) <= 2999
        })
        arrBackAdLoaded = arrBackAdLoaded.filter({ admobad in
            return now - TimeInterval(admobad.creatTime) <= 2999
        })
        ShowLog("[AD] 检测缓存地广告是否超时未使用完毕 loading:\(arrLoadingAdLoaded.count) connect:\(arrConnectAdLoaded.count) backHome:\(arrBackAdLoaded.count)")
    }
    
    //检测已经在请求的广告是否有成功
    func checkInterstitialAdOf(_ adType:InterstitialAdType, completeHandler:((_ isSuccess:Bool) -> Void)?){
        if !GoogleADManager.shared.isUserCanShowAd(){
            completeHandler?(false)
            return
        }
        ShowLog("[AD] \(adType.rawValue) 广告正在加载中")
        let dispatchTimer = DispatchSource.makeTimerSource(flags: [], queue: .main)
        var isFinishHandle = false //保证一次广告请求在规定时间内有且只有一起回调
        dispatchTimer.schedule(deadline: .now(), repeating: 1)
        dispatchTimer.setEventHandler(handler: { [weak self] in
            if adType == .loadingAD, let ads = self?.arrLoadingAdLoaded, ads.count > 0{
                dispatchTimer.cancel()
                isFinishHandle = true
                completeHandler?(true)
            }
            else if adType == .connectAD, let ads = self?.arrConnectAdLoaded, ads.count > 0{
                dispatchTimer.cancel()
                isFinishHandle = true
                completeHandler?(true)
            }
            else if adType == .backHomeAD, let ads = self?.arrBackAdLoaded, ads.count > 0{
                dispatchTimer.cancel()
                isFinishHandle = true
                completeHandler?(true)
                
            }
        })
        dispatchTimer.resume()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 13.4) {
            if isFinishHandle == false{
                ShowLog("[AD] \(adType.rawValue) 广告请求超时")
                dispatchTimer.cancel()
                isFinishHandle = true
                completeHandler?(false)
            }
        }
    }
    
    //插屏广告
    func requesAdOf(_ adType:InterstitialAdType, completeHandler:((_ isSuccess:Bool) -> Void)?){
        if !GoogleADManager.shared.isUserCanShowAd() {
            completeHandler?(false)
            return
        }
       
        //有缓存直接返回；正在加载广告则等待加载结果
        var currAdConfig:[GadConfigItemModel] = []
        if adType == .backHomeAD{
            if arrBackAdLoaded.count > 0 {
                ShowLog("[AD] \(adType.rawValue) 广告 有缓存")
                completeHandler?(true)
                return
            }
            if isbackAdRequesting {
                checkInterstitialAdOf(adType, completeHandler: completeHandler)
                return
            }
            isbackAdRequesting = true
            currAdConfig = GoogleADManager.shared.admobConfig?.arrBackHomeADConfig ?? []
            
        }
        else if adType == .loadingAD{
            if arrLoadingAdLoaded.count > 0 {
                ShowLog("[AD] \(adType.rawValue) 广告 有缓存")
                completeHandler?(true)
                return
            }
            if isLoadingAdRequesting {
                checkInterstitialAdOf(adType, completeHandler: completeHandler)
                return
            }
            currAdConfig = GoogleADManager.shared.admobConfig?.arrLoadingADConfig ?? []
            isLoadingAdRequesting = true
        }
        else if adType == .connectAD{
            if arrConnectAdLoaded.count > 0 {
                ShowLog("[AD] \(adType.rawValue) 广告 有缓存")
                completeHandler?(true)
                return
            }
            if isConnectAdRequesting {
                checkInterstitialAdOf(adType, completeHandler: completeHandler)
                return
            }
            currAdConfig = GoogleADManager.shared.admobConfig?.arrConnectADConfig ?? []
            isConnectAdRequesting = true
        }
        
        //广告加载流程
        var isFinishHandle = false //保证一次广告请求在规定时间内有且只有一起回调
        DispatchQueue.main.asyncAfter(deadline: .now() + 13.5) {
            if isFinishHandle == false{
                ShowLog("[AD] \(adType.rawValue) 广告请求超时")
                isFinishHandle = true
                completeHandler?(false)
            }
        }
        
        AdInterstitialLoader.init().requestAd(currAdConfig: currAdConfig, adType: adType, {[weak self] isSuccess, loadedAD in
            switch adType {
            case .backHomeAD:
                self?.isbackAdRequesting = false
                if isSuccess {
                    self?.arrBackAdLoaded.append(loadedAD!)
                }
            case .loadingAD:
                self?.isLoadingAdRequesting = false
                if isSuccess {
                    self?.arrLoadingAdLoaded.append(loadedAD!)
                }
            case .connectAD:
                self?.isConnectAdRequesting = false
                if isSuccess {
                    self?.arrConnectAdLoaded.append(loadedAD!)
                }
            }
            
            if isFinishHandle == false{
                isFinishHandle = true
                if isSuccess {
                    completeHandler?(true)
                }
                else{
                    completeHandler?(false)
                }
            }
        })
    }
}


class AdInterstitialLoader:NSObject{
    private var requestNum = 0

    func requestAd(currAdConfig:[GadConfigItemModel], adType:InterstitialAdType,  _ successHandler:((_ success:Bool, _ adLoaded:GadInterstitialLoadedModel?) -> Void)?) {
        if currAdConfig.count == 0 {
            successHandler?(false, nil)
        }
        let adid = currAdConfig[requestNum].adIdentifier ?? "null"
        let adPriority = currAdConfig[requestNum].adOrder ?? 99
        ShowLog("[AD] \(adType.rawValue) 开始加载第\(requestNum)个广告 id: \(adid); priority: \(adPriority)")
        GADInterstitialAd.load(withAdUnitID: adid, request: GADRequest()) { ad, error in
            if error == nil{
                if let ad = ad {
                    ShowLog("[AD] \(adType.rawValue) 广告加载成功 id: \(adid); priority: \(adPriority)")
                    let admobAd = GadInterstitialLoadedModel()
                    admobAd.adloaded = ad
                    admobAd.adIdentifier = adid
                    admobAd.adOrder = adPriority
                    admobAd.creatTime = Date().timeIntervalSince1970
                    successHandler?(true, admobAd)
                } else {
                    ShowLog("[AD] \(adType.rawValue) 广告加载失败 id: \(adid); priority: \(adPriority)")
                    self.requestNum += 1
                    if self.requestNum < currAdConfig.count{
                        self.requestAd(currAdConfig: currAdConfig, adType: adType, successHandler)
                    }
                    else{
                        successHandler?(false, nil)
                    }
                }
            }
            else{
                ShowLog("[AD] \(adType.rawValue) 广告加载失败 id: \(adid); priority: \(adPriority) error:\(error.debugDescription)")
                self.requestNum += 1
                if self.requestNum < currAdConfig.count{
                    self.requestAd(currAdConfig: currAdConfig, adType: adType, successHandler)
                }
                else{
                    successHandler?(false, nil)
                }
            }
        }
    }
}

