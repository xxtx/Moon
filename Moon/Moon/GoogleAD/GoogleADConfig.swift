//
//  GoogleADManager.swift
//  Moon
//
//  Created by ZY on 2022/6/8.
//

import Foundation
import GoogleMobileAds

let KeyOfShowClickCounts = "userShowClickCounts"        //用户广告展示点击次数缓存
let KeyOfUserMalignant = "isUserMalignant"              //恶意用户开始时间
let KeyOfFBAdConfig = "firbaseremoteAdConfig"           //远程广告配置
let notiNameCloseAllAD = Notification.Name(rawValue: "closeADForce")
let notiNameShowBackAD = Notification.Name(rawValue: "ShowBackAD")

enum InterstitialAdType: String, Codable {
    case loadingAD = "loading"
    case connectAD = "connect"
    case backHomeAD = "backHome"
}

enum NativeAdType: String, Codable {
    case homeAD = "homePage"
    case resultAD = "resultPage"
}

/// MARK: -- 本地展示点击数据
struct GadLocalCountModel: Codable  {
    var localDate = Date()
    var hasShowCounts: Int = 0
    var hasClickCounts: Int = 0
}

//单个广告配置
class GadConfigItemModel: Codable {
    var adIdentifier: String!
    var adOrder: Int!
}

//获取到的广告实例
class GadNativeLoadedModel: GadConfigItemModel {
    var creatTime: TimeInterval!
    var adloaded: GADNativeAd!
}

//获取到的广告实例
class GadInterstitialLoadedModel: GadConfigItemModel {
    var creatTime: TimeInterval!
    var adloaded: GADInterstitialAd!
}

//广告配置
class GadConfigModel: Codable {
    var arrHomeADConfig:[GadConfigItemModel] = []
    var arrResultADConfig:[GadConfigItemModel] = []
    var arrLoadingADConfig:[GadConfigItemModel] = []
    var arrConnectADConfig:[GadConfigItemModel] = []
    var arrBackHomeADConfig:[GadConfigItemModel] = []
    var dayShowLimits: Int = 0
    var dayClickLimits: Int = 0
}

let MainDateFormatter: DateFormatter = {
    let currFormatter = DateFormatter()
    currFormatter.dateFormat = "yyyy:MM:dd"
    return currFormatter
}()

class GoogleADManager: NSObject {
    static let shared = GoogleADManager.init()
    
    var adUserLocalCounts: GadLocalCountModel?    //用户的广告展示点击次数记录
    var admobConfig:GadConfigModel?               //广告配置
    
    private override init() {
        super.init()
        
        var configStr64 = ""
        if let adconfig = UserDefaults.standard.value(forKey: KeyOfFBAdConfig) as? String{
            configStr64 = adconfig
        }
        else{
            let filePath = Bundle.main.path(forResource: "admobConfig", ofType: "json")!
            let fileData = try! Data(contentsOf: URL(fileURLWithPath: filePath))
            configStr64 = fileData.base64EncodedString()
        }
        let data = Data(base64Encoded: configStr64)
        if let adConfig = try? JSONDecoder().decode(GadConfigModel.self, from: data ?? Data()){
            admobConfig = adConfig
            admobConfig!.arrHomeADConfig = admobConfig!.arrHomeADConfig.sorted(by: { return $0.adOrder > $1.adOrder })
            admobConfig!.arrResultADConfig = admobConfig!.arrResultADConfig.sorted(by: { return $0.adOrder > $1.adOrder })
            admobConfig!.arrConnectADConfig = admobConfig!.arrConnectADConfig.sorted(by: { return $0.adOrder > $1.adOrder })
            admobConfig!.arrLoadingADConfig = admobConfig!.arrLoadingADConfig.sorted(by: { return $0.adOrder > $1.adOrder })
            admobConfig!.arrBackHomeADConfig = admobConfig!.arrBackHomeADConfig.sorted(by: { return $0.adOrder > $1.adOrder })
            ShowLog("adConfig ~~~~ limitShow:\(admobConfig!.dayShowLimits), limitClick:\(admobConfig!.dayShowLimits)")
        }
        else{
            ShowLog("adConfig ~~~~ 获取失败")
        }
        
        getUserOperationData()
    }
    
    
    //展示点击次数更新
    func addUserShowCount() {
        adUserLocalCounts!.hasShowCounts += 1
        saveUserOperationLocal()
        ShowLog(" 广告展示 \(adUserLocalCounts!.hasShowCounts) 次")
    }
    
    func addUserClickCount(){
        adUserLocalCounts!.hasClickCounts += 1
        saveUserOperationLocal()
        ShowLog(" 广告点击 \(adUserLocalCounts!.hasClickCounts) 次")
    }
    
    
    
    //广告展示点击次数检测
    func isUserCanShowAd() -> Bool {
        if admobConfig == nil || admobConfig?.dayShowLimits == 0 {
            ShowLog("广告无配置文件")
            return false
        }
        
        if adUserLocalCounts!.hasShowCounts >= admobConfig!.dayShowLimits {
            ShowLog("总展示次数上限")
        }
        if adUserLocalCounts!.hasClickCounts >= admobConfig!.dayClickLimits {
            ShowLog("总点击次数上限")
        }
        
        var isIndengerTime = false
        if let abnormalTime = UserDefaults.standard.value(forKey: KeyOfUserMalignant) as? TimeInterval {
            if Date().timeIntervalSince1970 - abnormalTime < 48 * 60 * 60 {
                ShowLog("异常点击用户")
                isIndengerTime = true
            }
            UserDefaults.standard.removeObject(forKey: KeyOfUserMalignant)
        }
        
        if !isIndengerTime, adUserLocalCounts!.hasShowCounts < admobConfig!.dayShowLimits, adUserLocalCounts!.hasClickCounts < admobConfig!.dayClickLimits{
            return true
        }
        else{
            NotificationCenter.default.post(name: notiNameCloseAllAD, object: nil)
            return false
        }
    }
    
    //展示、点击次数 缓存
    func getUserOperationData() {
        if adUserLocalCounts == nil{
            if let localData = UserDefaults.standard.value(forKey: KeyOfShowClickCounts) as? Data,
               let loacalCounts = try? JSONDecoder().decode(GadLocalCountModel.self, from: localData) {
                if MainDateFormatter.string(from: loacalCounts.localDate) == MainDateFormatter.string(from: Date()) {
                    adUserLocalCounts = loacalCounts
                }
                else{
                    UserDefaults.standard.removeObject(forKey: KeyOfShowClickCounts)
                    adUserLocalCounts = GadLocalCountModel()
                    saveUserOperationLocal()
                }
            } else {
                adUserLocalCounts = GadLocalCountModel()
                saveUserOperationLocal()
            }
        }
        else{
            if MainDateFormatter.string(from: adUserLocalCounts!.localDate) != MainDateFormatter.string(from: Date()){
                UserDefaults.standard.removeObject(forKey: KeyOfShowClickCounts)
                adUserLocalCounts = GadLocalCountModel()
                saveUserOperationLocal()
            }
        }
    }
    
    //刷新广告展示点击的缓存次数
    private func saveUserOperationLocal(){
        do {
            let data = try JSONEncoder().encode(adUserLocalCounts)
            UserDefaults.standard.setValue(data, forKey: KeyOfShowClickCounts)
        } catch let e {
            ShowLog("用户广告展示点击存储失败 \(e.localizedDescription)")
        }
    }
}
