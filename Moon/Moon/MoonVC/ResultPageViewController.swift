//
//  ResultPageViewController.swift
//  Moon
//
//  Created by ZY on 2022/6/1.
//

import Foundation
import UIKit
import GoogleMobileAds

class ResultPageViewController:UIViewController, GADNativeAdDelegate{
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .darkContent
    }
    var connectState:ConnectState!
    var isSuccess = true
    var clickHandle:(() -> Void)?
    
    @IBOutlet weak var stateImg:UIImageView!
    @IBOutlet weak var stateLab:UILabel!
    @IBOutlet weak var descLab:UILabel!
    @IBOutlet weak var connectBtn:UIButton!
    @IBOutlet weak var adBGView:UIView!
    
    lazy var resultAdView = ResultADView.init(frame: CGRect(x: 0, y: 0, width: SCREENW - 40, height: (SCREENW - 40)*310/335))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        adBGView.addSubview(resultAdView)
        
        
        if connectState == .connected {
            stateImg.image = UIImage(named: "connectedLight")
            stateLab.text = "Connected Successful!"
            descLab.text = "Real-time internet speed monitoring is enabled"
            connectBtn.setTitle("Select new servers", for: .normal)
        }
        else{
            stateImg.image = UIImage(named: "disconnectedLight")
            stateLab.text = "Disconnected"
            descLab.text = ""
            connectBtn.setTitle("Connect again", for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if resultAdView.isHidden == true{
            requstResultAD()
        }
    }
    
    @IBAction func backClick(){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func connectClick(){
        self.navigationController?.popViewController(animated: false)
        self.clickHandle?()
    }
    
    func requstResultAD(){
        if self.viewIfLoaded?.window == nil {
            return
        }
        GadNativeLoader.shared.requesAdOf(.resultAD) {[weak self] isSuccess in
            if isSuccess{
                if let admob = GadNativeLoader.shared.arrResultAdLoaded.first{
                    self?.resultAdView.isHidden = false
                    self?.resultAdView.nativeAd = admob.adloaded
                    self?.resultAdView.nativeAd!.delegate = self
                    ShowLog("[AD] \(NativeAdType.resultAD) 广告展示 ID:\(admob.adIdentifier ?? ""), level:\(admob.adIdentifier ?? "")")
                    GadNativeLoader.shared.arrResultAdLoaded.removeFirst()
                    GoogleADManager.shared.addUserShowCount()
                    return
                }
            }
        }
    }

    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        GoogleADManager.shared.addUserClickCount()
    }
}
