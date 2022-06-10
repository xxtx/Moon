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

//    private var timercheckADCash:Timer?
    private override init() {
        super.init()
        Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(removeAdCashOutTime), userInfo: nil, repeats: true)
    }
    
    @objc func removeAdCashOutTime() {
        ShowLog("开始检测缓存地广告是否超时未使用 loading:\(arrLoadingAdLoaded.count) connect:\(arrConnectAdLoaded.count) backHome:\(arrBackAdLoaded.count)")
        let now = Date().timeIntervalSince1970
        arrLoadingAdLoaded = arrLoadingAdLoaded.filter({ admobad in
            return now - TimeInterval(admobad.creatTime) < 3000
        })
        arrConnectAdLoaded = arrConnectAdLoaded.filter({ admobad in
            return now - TimeInterval(admobad.creatTime) < 3000
        })
        arrBackAdLoaded = arrBackAdLoaded.filter({ admobad in
            return now - TimeInterval(admobad.creatTime) < 3000
        })
        ShowLog("检测缓存地广告是否超时未使用完毕 loading:\(arrLoadingAdLoaded.count) connect:\(arrConnectAdLoaded.count) backHome:\(arrBackAdLoaded.count)")
    }
    
    
    //检测已经在请求的广告是否有成功
    func checkInterstitialAdOf(_ adType:InterstitialAdType, completeHandler:((_ isSuccess:Bool) -> Void)?){
        ShowLog("\(adType.rawValue) 广告正在加载中")
        let dispatchTimer = DispatchSource.makeTimerSource(flags: [], queue: .main)
        var isFinishHandle = false //保证一次广告请求在规定时间内有且只有一起回调
        dispatchTimer.schedule(deadline: .now(), repeating: 1)
        dispatchTimer.setEventHandler(handler: { [weak self] in
            switch adType{
            case .loadingAD:
                if let ads = self?.arrLoadingAdLoaded, ads.count > 0{
                    dispatchTimer.cancel()
                    isFinishHandle = true
                    completeHandler?(true)
                }
            case .connectAD:
                if let ads = self?.arrConnectAdLoaded, ads.count > 0{
                    dispatchTimer.cancel()
                    isFinishHandle = true
                    completeHandler?(true)
                }
            case .backHomeAD:
                if let ads = self?.arrBackAdLoaded, ads.count > 0{
                    dispatchTimer.cancel()
                    isFinishHandle = true
                    completeHandler?(true)
                }
            }
        })
        dispatchTimer.resume()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 13.4) {
            if isFinishHandle == false{
                ShowLog("\(adType.rawValue) 广告请求超时")
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
        switch adType {
        case .backHomeAD:
            if arrBackAdLoaded.count > 0 {
                ShowLog("\(adType.rawValue) 广告 有缓存")
                completeHandler?(true)
                return
            }
            if isbackAdRequesting {
                checkInterstitialAdOf(adType, completeHandler: completeHandler)
                return
            }
            currAdConfig = GoogleADManager.shared.admobConfig?.arrBackHomeADConfig ?? []
            isbackAdRequesting = true
        
        case .loadingAD:
            if arrLoadingAdLoaded.count > 0 {
                ShowLog("\(adType.rawValue) 广告 有缓存")
                completeHandler?(true)
                return
            }
            if isLoadingAdRequesting {
                checkInterstitialAdOf(adType, completeHandler: completeHandler)
                return
            }
            currAdConfig = GoogleADManager.shared.admobConfig?.arrLoadingADConfig ?? []
            isLoadingAdRequesting = true

        case .connectAD:
            if arrConnectAdLoaded.count > 0 {
                ShowLog("\(adType.rawValue) 广告 有缓存")
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
                ShowLog("\(adType.rawValue) 广告请求超时")
                isFinishHandle = true
                completeHandler?(false)
            }
        }
        let _ = AdInterstitialLoader.init(adType, currAdConfig: currAdConfig, successHandler:{[weak self] isSuccess, loadedAD in
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
    private var requestIndex = 0
    
    init(_ adType:InterstitialAdType, currAdConfig:[GadConfigItemModel], successHandler:((_ success:Bool, _ adLoaded:GadInterstitialLoadedModel?) -> Void)?) {
        super.init()
        if currAdConfig.count == 0 {
            successHandler?(false, nil)
        }
        else {
            self.requestInterstitialAd(adType, currAdConfig:currAdConfig, successHandler)
        }
    }

    func requestInterstitialAd(_ adType:InterstitialAdType, currAdConfig:[GadConfigItemModel], _ successHandler:((_ success:Bool, _ adLoaded:GadInterstitialLoadedModel?) -> Void)?) {
        let adid = currAdConfig[requestIndex].adIdentifier ?? "null"
        let adPriority = currAdConfig[requestIndex].adOrder ?? 99
        ShowLog("\(adType.rawValue) 开始加载第\(requestIndex)个广告 id: \(adid); priority: \(adPriority)")
        GADInterstitialAd.load(withAdUnitID: adid, request: GADRequest()) { ad, error in
            guard error == nil else {
                ShowLog("\(adType.rawValue) 广告加载失败 id: \(adid); priority: \(adPriority) error:\(error.debugDescription)")
                if self.requestIndex + 1 == currAdConfig.count{
                    successHandler?(false, nil)
                }
                else{
                    self.requestIndex += 1
                    self.requestInterstitialAd(adType, currAdConfig: currAdConfig, successHandler)
                }
                return
            }
            if let ad = ad {
                ShowLog("\(adType.rawValue) 广告加载成功 id: \(adid); priority: \(adPriority)")
                let admobAd = GadInterstitialLoadedModel()
                admobAd.adIdentifier = adid
                admobAd.adOrder = adPriority
                admobAd.adloaded = ad
                admobAd.creatTime = Date().timeIntervalSince1970
                successHandler?(true, admobAd)
            } else {
                ShowLog("\(adType.rawValue) 广告加载失败 id: \(adid); priority: \(adPriority)")
                if self.requestIndex + 1 == currAdConfig.count{
                    successHandler?(false, nil)
                }
                else{
                    self.requestIndex += 1
                    self.requestInterstitialAd(adType, currAdConfig: currAdConfig, successHandler)
                }
            }
        }
    }
}

