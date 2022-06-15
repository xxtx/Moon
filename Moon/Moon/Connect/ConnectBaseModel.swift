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
var serverLists = [
    SeverModel(serverIcon: "england", serverCountry: "London", serverHost: "45.10.58.187"),
    SeverModel(serverIcon: "america", serverCountry: "New York", serverHost: "79.133.110.34"),
    SeverModel(serverIcon: "america", serverCountry: "Chicago", serverHost: "92.38.176.83")]

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

/*
[
    {
        "serverCountry":"New York",
        "serverIcon":"america",
        "serverHost":"79.133.110.34",
        "serverSpeed":9999
    },
    {
        "serverCountry":"Chicago",
        "serverIcon":"america",
        "serverHost":"92.38.176.83",
        "serverSpeed":9999
    },
    {
        "serverCountry":"London",
        "serverIcon":"england",
        "serverHost":"45.10.58.187",
        "serverSpeed":9999
    }
]
 */
