//
//  ConnectBaseModel.swift
//  Moon
//
//  Created by ZY on 2022/6/1.
//

import Foundation

//是否进入用户设置tunnel
var isInConnectSetting = false

//tunnel 本地配置
var serverLists = [SeverModel(serverIcon: "icon_america", serverCountry: "New York", serverHost: "79.133.121.16"),
                     SeverModel(serverIcon: "icon_america", serverCountry: "Miami", serverHost: "92.38.132.33"),
                    SeverModel(serverIcon: "icon_england", serverCountry: "London", serverHost: "5.181.27.158"),
                    SeverModel(serverIcon: "", serverCountry: "error country", serverHost: " ")]

class SeverModel:Codable {
    var serverIcon: String = ""
    var serverCountry: String = ""
    var serverHost: String = ""
    var serverSpeed: Double = 0.0
    
    init(serverIcon:String?, serverCountry: String?, serverHost: String?) {
        self.serverCountry = serverCountry ?? ""
        self.serverIcon = serverIcon ?? ""
        self.serverHost = serverHost ?? ""
    }
    required init?(coder: NSCoder) {
        fatalError("init(code:) has not been impleted")
    }
}

//tunnel 状态
enum ConnectState {
    case waitConnect
    case connecting
    case connected
    case disConnecting
    case disConnected
    case reConnecting
    case error
    case noNetwork
}
