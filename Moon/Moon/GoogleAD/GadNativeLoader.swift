//
//  GadNativeLoader.swift
//  Moon
//
//  Created by ZY on 2022/6/8.
//

import Foundation
import GoogleMobileAds

class GadNativeLoader: NSObject {
    static let shared = GadNativeLoader.init()
    
    // homePage waterfall相关
    private var isHomeAdLoading = false
    var arrMainAdLoaded = [GadNativeLoadedModel]()
    var homeAdLoader:AdNativeLoader?
    
    // connectResult waterfall相关
    private var isResultAdLoading = false
    var arrResultAdLoaded = [GadNativeLoadedModel]()
    var resultAdLoader:AdNativeLoader?
    
//    private var timercheckADCash:Timer?
    private override init() {
        super.init()
        Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(removeAdCashOutTime), userInfo: nil, repeats: true)
    }
    
    //检测已经在请求的广告是否有成功
    private func checkNativeAdOf(_ adType:NativeAdType, completeHandler:((_ isSuccess:Bool) -> Void)?){
        ShowLog("[AD] \(adType.rawValue) 广告正在加载中")
        var isFinishHandle = false //保证一次广告请求在规定时间内有且只有一起回调
        let dispatchTimer = DispatchSource.makeTimerSource(flags: [], queue: .main)
        dispatchTimer.setEventHandler(handler: { [weak self] in
            if adType == .homeAD, let ads = self?.arrMainAdLoaded, ads.count > 0{
                dispatchTimer.cancel()
                isFinishHandle = true
                completeHandler?(true)
            }
            else if adType == .resultAD, let ads = self?.arrResultAdLoaded, ads.count > 0{
                dispatchTimer.cancel()
                isFinishHandle = true
                completeHandler?(true)
            }
        })
        dispatchTimer.schedule(deadline: .now(), repeating: 2)
        dispatchTimer.resume()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
            if isFinishHandle == false{
                ShowLog("[AD] \(adType.rawValue) 广告请求超时")
                dispatchTimer.cancel()
                isFinishHandle = true
                completeHandler?(false)
            }
        }
    }
    
    @objc private func removeAdCashOutTime() {
        ShowLog("[AD] 开始检测缓存地广告是否超时未使用 main:\(arrMainAdLoaded.count) result:\(arrResultAdLoaded.count)")
        let now = Date().timeIntervalSince1970
        arrMainAdLoaded = arrMainAdLoaded.filter({ admobad in
            return now - TimeInterval(admobad.creatTime) <= 2999
        })
        arrResultAdLoaded = arrResultAdLoaded.filter({ admobad in
            return now - TimeInterval(admobad.creatTime) <= 2999
        })
        ShowLog("[AD] 检测缓存地广告是否超时未使用完毕 main:\(arrMainAdLoaded.count) result:\(arrResultAdLoaded.count)")
    }
    
    //原生广告
    func requesAdOf(_ adType:NativeAdType, completeHandler:((_ isSuccess:Bool) -> Void)?){
        if !GoogleADManager.shared.isUserCanShowAd() {
            completeHandler?(false)
            return
        }
        
        var currAdConfig:[GadConfigItemModel] = []
        if adType == .homeAD{
            if arrMainAdLoaded.count > 0 {
                ShowLog("[AD] \(adType.rawValue) 广告 有缓存")
                completeHandler?(true)
                return
            }
            if isHomeAdLoading {
                checkNativeAdOf(adType, completeHandler: completeHandler)
                return
            }
            isHomeAdLoading = true
            currAdConfig = GoogleADManager.shared.admobConfig?.arrHomeADConfig ?? []
        }
        else if adType == .resultAD{
            if arrResultAdLoaded.count > 0 {
                ShowLog("[AD] \(adType.rawValue) 广告 有缓存")
                completeHandler?(true)
                return
            }
            if isResultAdLoading {
                checkNativeAdOf(adType, completeHandler: completeHandler)
                return
            }
            isResultAdLoading = true
            currAdConfig = GoogleADManager.shared.admobConfig?.arrResultADConfig ?? []
        }
        
        //广告加载流程
        var isFinishHandle = false //保证一次广告请求在规定时间内有且只有一起回调
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
            if isFinishHandle == false{
                ShowLog("[AD] \(adType.rawValue) 广告请求超时")
                isFinishHandle = true
                completeHandler?(false)
            }
        }
        
        let loader = AdNativeLoader.init(adType, currAdConfig: currAdConfig) {[weak self] isSuccess, adLoaded in
            if adType == .homeAD{
                self?.isHomeAdLoading = false
                if isSuccess {
                    self?.arrMainAdLoaded.append(adLoaded!)
                }
            }
            else if adType == .resultAD{
                self?.isResultAdLoading = false
                if isSuccess {
                    self?.arrResultAdLoaded.append(adLoaded!)
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
            
            switch adType {
            case .homeAD:
                self?.homeAdLoader = nil
            case .resultAD:
                self?.resultAdLoader = nil
            }
        }
        
        switch adType {
        case .homeAD:
            homeAdLoader = loader
        case .resultAD:
            resultAdLoader = loader
        }
    }

}

class AdNativeLoader:NSObject, GADAdLoaderDelegate, GADNativeAdLoaderDelegate {
    private var requestIndex = 0
    private var adType:NativeAdType!
    private var currAdConfig:[GadConfigItemModel]? //用于获取广告地配置
    private var adLoader:GADAdLoader?
    private var successHandler:((_ success:Bool, _ adExa:GadNativeLoadedModel?) -> Void)?
    
     
    init(_ adType:NativeAdType, currAdConfig:[GadConfigItemModel], successHandler:((_ success:Bool, _ adLoaded:GadNativeLoadedModel?) -> Void)?) {
        super.init()
        if currAdConfig.count == 0 {
            successHandler?(false, nil)
        }
        else {
            self.adType = adType
            self.successHandler = successHandler
            self.currAdConfig = currAdConfig
            self.requestNativeAdmob()
        }
    }
    
    func requestNativeAdmob() {
        let adid = currAdConfig?[requestIndex].adIdentifier ?? "null"
        let adPriority = currAdConfig?[requestIndex].adOrder ?? 99
        ShowLog("[AD] \(adType.rawValue) 开始加载第\(requestIndex)个广告 id: \(adid); priority: \(adPriority)")
        adLoader = GADAdLoader(adUnitID:adid, rootViewController: nil, adTypes: [.native], options: nil)
        adLoader!.delegate = self
        adLoader!.load(GADRequest())
    }
    
    //nativeAD 代理
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        ShowLog("[AD] \(adType.rawValue) 广告加载失败 \(error.localizedDescription)")
        requestIndex += 1
        if requestIndex >= currAdConfig?.count ?? 0 {
            successHandler?(false, nil)
        }
        else{
            requestNativeAdmob()
        }
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        ShowLog("[AD] \(adType.rawValue) 广告加载成功")
        let ad = GadNativeLoadedModel()
        ad.creatTime = Date().timeIntervalSince1970
        ad.adloaded = nativeAd
        ad.adIdentifier = currAdConfig?[requestIndex].adIdentifier
        ad.adOrder = currAdConfig?[requestIndex].adOrder
        successHandler?(true, ad)
    }
}
