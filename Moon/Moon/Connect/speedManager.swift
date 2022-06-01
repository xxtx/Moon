//
//  speedManager.swift
//  Moon
//
//  Created by ZY on 2022/6/1.
//

import Foundation

class SpeedTestManager:NSObject{
    static let shareInstance = SpeedTestManager()
    
    func testServerList(_ lists: [SeverModel], completion: (([SeverModel]) -> Void)?) {
        var testResults = [Int : [Double]]()
        for (index, _) in lists.enumerated() {
            testResults[index] = [Double]()
        }
        var testDictionaryTemp = [Int : PingManager?]()
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue.main
        for (index, server) in lists.enumerated() {
            dispatchGroup.enter()
            PingManager.shared().queueCount += 1
            dispatchQueue.async {
//                MainFBLog.logEvent(.smartPA, ["tunnel":server.serverHost])
                testDictionaryTemp[index] = PingManager.startPingHost(server.serverHost, count: 3, pingRedultCallback: { pingItem in
                    switch pingItem.status {
                    case start:
                        break
                    case receivePacket:
//                        MainFBLog.logEvent(.smartPB, ["tunnel":server.serverHost])
                        testResults[index]?.append(pingItem.singleTime)
                        dispatchGroup.leave()
                        PingManager.shared().queueCount -= 1
                    case failToSendPacket:
                        dispatchGroup.leave()
                        PingManager.shared().queueCount -= 1
                        break
                    case receiveUnpectedPacket:
                        break
                    case error:
                        testResults[index]?.append(9999)
                        dispatchGroup.leave()
                        PingManager.shared().queueCount -= 1
                    case timeout:
                        testResults[index]?.append(9999)
                        dispatchGroup.leave()
                        PingManager.shared().queueCount -= 1
                    case finished:
                        testDictionaryTemp[index] = nil
                        dispatchGroup.leave()
                        PingManager.shared().queueCount -= 1
                    default: break
                    }
                })
            }
        }
        dispatchGroup.notify(queue: dispatchQueue) {
            var pingTempResult = [Int : Double]()
            for ping in testResults {
                var sum = 0.0
                for pingTime in ping.value {
                    sum += pingTime
                }
                if ping.value.count > 0 {
                    let avg = sum / Double(ping.value.count)
                    pingTempResult[ping.key] = avg
                }
            }
            if pingTempResult.count == 0 {
                ShowLog("[tunnel] Error ping avg resut count == 0")
                return
            }
            let needPingServers = lists
            for pingAvg in pingTempResult {
                needPingServers[pingAvg.key].serverSpeed = pingAvg.value
            }
            let sortedVPNServers = needPingServers.sorted(by: { return $0.serverSpeed < $1.serverSpeed })
            ShowLog("[tunnel] [tunnel] Ping result:")
            for (index, sortedServer) in sortedVPNServers.enumerated() {
                ShowLog("[tunnel] \(index):\(sortedServer.serverCountry) - \(sortedServer.serverHost) - \(String(format: "%.2f", sortedServer.serverSpeed))ms")
            }
            let sortedServersCanUse = sortedVPNServers.filter({$0.serverSpeed < 9998})
            completion?(sortedServersCanUse)
        }
    }
    
    
}
