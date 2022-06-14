//
//  GoogleFBLog.swift
//  Moon
//
//  Created by ZY on 2022/6/14.
//

import Foundation
import FirebaseAnalytics
import FirebaseRemoteConfig


enum LogEvevts: String {
    case Fa
    case Fb
    case Fc
    case S1
    case S2
    case MA
    case MB
    case MC
    case MD
    case ME
    case H2
    case H3
    case H4
    case Q
    case D
}

class GoogleFBLog {
    static func logEvent(_ event:LogEvevts, _ params:[String:Any] = [:]){
#if DEBUG
        ShowLog("[FB] event: \(event.rawValue)   params: \(params)")
#else
        Analytics.logEvent(event.rawValue, parameters: params)
#endif
    }
    
    static func setProperty(_ prop:String, for name: String){
#if DEBUG
        ShowLog("[FB] Property: \(prop)   forName: \(name))")
#else
        Analytics.setUserProperty(prop, forName: name)
#endif
    }
}


///firebase remote config
let KEYRemoteServerConfig = "KEYRemoteServerConfig"
let KEYRemoteAdConfig = "KEYRemoteAdConfig"
class GoogleFBRemoteManager: NSObject {
    static let shared = GoogleFBRemoteManager()
    let remoteConfig = RemoteConfig.remoteConfig()
    private override init() {
        super.init()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
    }
    
    func requestRemoteConfig(){
        remoteConfig.fetch { (status, error) -> Void in
            if status == .success {
                self.remoteConfig.activate { changed, error in
                    if let servercon = self.remoteConfig.configValue(forKey: "serversConfig").stringValue{
                        UserDefaults.standard.setValue(servercon, forKey: KEYRemoteServerConfig)
                    }
                    if let adcon = self.remoteConfig.configValue(forKey: "adConfig").stringValue{
                        UserDefaults.standard.setValue(adcon, forKey: KEYRemoteAdConfig)
                    }
                }
            } else {
                print("Config Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
}




