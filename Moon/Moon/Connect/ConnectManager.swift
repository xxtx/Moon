//
//  ConnectManager.swift
//  Moon
//
//  Created by ZY on 2022/6/1.
//

import Foundation
import NetworkExtension
import Reachability

class ConnectManager: NSObject {
    static let shareInstance = ConnectManager()
    var connectStateChangeHandle: ((_ tunnelState: ConnectState) -> Void)?
    
    var hasNetworkProvider = false
    var hasConnectFirst = true      //是否进行了第一次连接，排出第一次连接返回的disconnect状态
    var hasNetworkObserver = false
    
    var providerManager: NETunnelProviderManager?
    var timeoutTimer: DispatchSourceTimer?
    var reconnectTimer: DispatchSourceTimer?

    func connectStateChangeTo(status: NEVPNStatus) {
        switch status {
        case .connecting:
            ShowLog("[tunnel] state connecting")
            connectStateChangeHandle?(.connecting)
            addConnectTimeoutTimer()
        case .disconnecting:
            ShowLog("[tunnel] state disconnecting")
            connectStateChangeHandle?(.disConnecting)
            removeConnectTimeoutTimer()
        case .connected:
            ShowLog("[tunnel] state connected")
            removeConnectTimeoutTimer()
            if hasNetworkProvider{
                connectStateChangeHandle?(.connected)
            }
        case .disconnected:
            ShowLog("[tunnel] state disconnected")
            connectStateChangeHandle?(.disConnected)
            removeConnectTimeoutTimer()
        case .invalid:
            ShowLog("[tunnel] state invalid")
            connectStateChangeHandle?(.error)
            removeConnectTimeoutTimer()
        case .reasserting:
            ShowLog("[tunnel] state reconnecting")
            connectStateChangeHandle!(.reConnecting)
        default:
            ShowLog("[tunnel] state status unkonwn")
        }
    }
    
    // 链接超时
    func addConnectTimeoutTimer(_ timeout:TimeInterval = 14) {
        timeoutTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        timeoutTimer?.setEventHandler(handler: {
            DispatchQueue.main.async {
                ShowLog("[tunnel] timeout invalid")
                if self.hasNetworkObserver {
                    NotificationCenter.default.removeObserver(self)
                    self.hasNetworkObserver = false
                }
                self.connectStateChangeTo(status: .invalid)
                self.disconnectServer()
            }
        })
        timeoutTimer?.schedule(deadline: .now() + timeout)
        timeoutTimer?.resume()
    }

    func removeConnectTimeoutTimer() {
        timeoutTimer?.cancel()
        timeoutTimer = nil
    }
    
    private func addconnectStateNotifocation() {
        if hasNetworkObserver { return }
        hasNetworkObserver = true
        NotificationCenter.default.addObserver(self, selector: #selector(providerStateChanged(noti:)), name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
    }
    @objc private func providerStateChanged(noti: Notification) {
        if let session = noti.object as? NETunnelProviderSession {
            if session != providerManager?.connection { return }
        }
        guard providerManager != nil  else {
            return
        }
        connectStateChangeTo(status: providerManager!.connection.status)
    }
    
    
    func loadProviderConfiguration(stateHandle: ((_ tunnelStatus: NEVPNStatus) -> Void)?) {
        NETunnelProviderManager.loadAllFromPreferences { manager, error in
            guard error == nil else {
                ShowLog("\(error?.localizedDescription ?? "")")
                self.hasNetworkProvider = false
                return
            }
            if let first = manager?.first {
                stateHandle?(first.connection.status)
                self.providerManager = first
                self.hasNetworkProvider = true
            } else {
                self.hasNetworkProvider = false
                self.providerManager = NETunnelProviderManager()
            }
            self.addconnectStateNotifocation()
        }
    }
    

    func setupServerProvider(completion: (() -> Void)?) {
        providerManager?.loadFromPreferences(completionHandler: { error in
            guard error == nil else {
                ShowLog("[tunnel] ERROR \(error?.localizedDescription ?? "")")
                self.hasNetworkProvider = false
                return
            }
            if self.hasNetworkProvider == false{
//                MainFBLog.logEvent(.smartAthA)
                self.hasConnectFirst = false
            }
            
            let tunnelProtocol = NETunnelProviderProtocol()
            tunnelProtocol.serverAddress = "SpeedTunnel"
            tunnelProtocol.providerBundleIdentifier = "com.demo.ofzy.SpeedTunnel.SpeedTunnelNetWork"
            let rule = NEOnDemandRuleConnect()
            rule.interfaceTypeMatch = .any
            self.providerManager?.protocolConfiguration = tunnelProtocol
            self.providerManager?.onDemandRules = [rule]
            self.providerManager?.isEnabled = true
            isInConnectSetting = true
            self.providerManager?.saveToPreferences { error in
                guard error == nil else {
                    self.hasNetworkProvider = false
                    isInConnectSetting = false
                    ShowLog("[tunnel] SavePreferences error: \(error?.localizedDescription ?? "")")
                    self.connectStateChangeHandle?(.waitConnect)
                    return
                }
                if self.hasNetworkProvider == false{
                    self.hasNetworkProvider = true
//                    MainFBLog.logEvent(.smartAthB)
                }
                self.hasNetworkProvider = true
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                    isInConnectSetting = false
                    completion?()
                }
            }
        })
    }
    
    func connectServer(_ server:SeverModel, _ isfast:Bool = true) {
        let reachability = try! Reachability()
        if reachability.connection == .unavailable {
            ShowLog("[tunnel] Network is not reachable")
            connectStateChangeHandle?(.noNetwork)
            return
        }
//        FireBaseLog.log(event: .fast_c, ["fast": isfast ? "fast" : server.serverIcon])
        self.addconnectStateNotifocation()
        self.providerManager?.loadFromPreferences { error in
            guard error == nil else {
                ShowLog("[tunnel] load error: \(error?.localizedDescription ?? "")")
                self.connectStateChangeHandle?(.noNetwork)
                return
            }
            do {
                try self.providerManager?.connection.startVPNTunnel(options: ["host":NSString(string:   server.serverHost),"port":"1206","method":"chacha20-ietf-poly1305","password":"S9E9Tx5P6Y(Kp_pm"])
                ShowLog("[tunnel] host : \(server.serverHost)")
            } catch let e {
                ShowLog("[tunnel] connect error: \(e.localizedDescription)")
                self.connectStateChangeHandle?(.noNetwork)
            }
        }
    }
    
    func disconnectServer() {
        self.providerManager?.connection.stopVPNTunnel()
    }
}
