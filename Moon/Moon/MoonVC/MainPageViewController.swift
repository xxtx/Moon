//
//  MainPageViewController.swift
//  Moon
//
//  Created by ZY on 2022/5/31.
//

import Foundation
import UIKit
import Lottie
import Reachability
import ZKProgressHUD

class MainPageViewController:UIViewController{
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .darkContent
    }
    static var shared = BaseNavigationController.init(rootViewController: MainStoryBoard.instantiateViewController(withIdentifier: "MainPageViewController"))
    
    @IBOutlet weak var imgBG:UIImageView!
    @IBOutlet weak var logoLab:UILabel!
    @IBOutlet weak var settingBtn:UIButton!
    @IBOutlet weak var countryBG:UIImageView!
    @IBOutlet weak var selCountryImg:UIImageView!
    @IBOutlet weak var selCountryLab:UILabel!
    @IBOutlet weak var selImg:UIImageView!
    
    @IBOutlet weak var countryView:UIView!
    @IBOutlet weak var lightImgv:UIImageView!
    @IBOutlet weak var settingCoverView:UIView!
    @IBOutlet weak var constraintSettingBottom:NSLayoutConstraint!
    
    @IBOutlet weak var connectBtn:UIButton!
    @IBOutlet weak var connectingImg:UIImageView!
    @IBOutlet weak var stateLab:UILabel!
    @IBOutlet weak var downSpeedLab:UILabel!
    @IBOutlet weak var downUnitLab:UILabel!
    @IBOutlet weak var upSpeedLab:UILabel!
    @IBOutlet weak var upUnitLab:UILabel!
    
    @IBOutlet weak var downBGView:UIView!
    @IBOutlet weak var upBGView:UIView!
    @IBOutlet weak var downLine:UIView!
    @IBOutlet weak var upLine:UIView!
    
    private var isServerListsBackReconnect = false
    private var serverRandom:SeverModel? //随机连接一个ping通服务器
    private var connectState:ConnectState = .waitConnect{
        didSet{
            switch connectState {
            case .connecting, .reConnecting:
                self.showConnecting()
            case .connected:
                self.showConnected()
            case .disConnecting:
                self.showDisconnecting()
            default:
                self.showDisconnected()
            }
        }
    }
    private var choiceServerIndex:Int = 0{
        didSet{
            if choiceServerIndex == 0{
                selCountryImg.image = UIImage(named: "countrymoon")
                selCountryLab.text = "Smart Server"
            }
            else{
                let tunnelM = serverLists[choiceServerIndex - 1]
                selCountryImg.image = UIImage(named: tunnelM.serverIcon)
                selCountryLab.text = tunnelM.serverCountry
            }
        }
    }
    
    
    //链接动画
    lazy var connectingAnimationView: AnimationView = {
        let animationView = AnimationView(name: "connectingAni")
        animationView.frame = lightImgv.bounds
        animationView.loopMode = .loop
        animationView.isHidden = false
        return animationView
    }()
    
    //链接动画
    lazy var disconnectingAnimationView: AnimationView = {
        let animationView = AnimationView(name: "disconnectingAni")
        animationView.frame = lightImgv.bounds
        animationView.loopMode = .loop
        animationView.isHidden = true
        return animationView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        let tap1 = UITapGestureRecognizer.init(target: self, action: #selector(choiceCountry))
        countryView.addGestureRecognizer(tap1)
        
        let tap2 = UITapGestureRecognizer.init(target: self, action: #selector(closeSettingView))
        settingCoverView.addGestureRecognizer(tap2)
        
        ConnectManager.shareInstance.loadProviderConfiguration { tunnelStatus in
            if tunnelStatus == .connected{
                self.connectState = .connected
            }
        }
        setConnectManagerHandle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lightImgv.addSubview(connectingAnimationView)
        lightImgv.addSubview(disconnectingAnimationView)
        downBGView.addSubview(downAniView)
        upBGView.addSubview(upAniView)
        
        if connectState == .connected{
            changeSpeedByte(true)
        }
    }
    
    @objc func choiceCountry(){
        if connectState == .connecting || connectState == .disConnecting || connectState == .reConnecting{ return }
        let vc = ServerlistViewController.init()
        vc.selectIndex = choiceServerIndex
        vc.connectState = connectState
        vc.selcctHandle = { [weak self] selIndex in
            self?.choiceServerIndex = selIndex
            if self?.connectState == .connected{
                self?.isServerListsBackReconnect = true
                ConnectManager.shareInstance.disconnectServer()
                self?.connectState = .connecting
            }
            else{
                self?.connectServer()
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func closeSettingView(){
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.settingCoverView.backgroundColor = UIColor(rgb: 0x000000, alpha: 0)
            self.constraintSettingBottom.constant = -470
            self.view.layoutIfNeeded()
        } completion: { isfinish in
            if isfinish{
                self.settingCoverView.isHidden = true
            }
        }
    }
    
    @IBAction func btnSettingClick(){
        if connectState == .connecting || connectState == .disConnecting || connectState == .reConnecting{ return }
        settingCoverView.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.settingCoverView.backgroundColor = UIColor(rgb: 0x000000, alpha: 0.6)
            self.constraintSettingBottom.constant = 0
            self.view.layoutIfNeeded()
        } completion: { isfinish in}
    }
    
    @IBAction func btnConnectClick(){
        if connectState == .connecting || connectState == .disConnecting || connectState == .reConnecting{ return }
        switch connectState {
        case .waitConnect, .disConnected, .error, .noNetwork:
            connectServer()
        case .connected:
            disconnectServer()
        default:
            break
        }
    }
    
    
    private func connectServer(){
        if ConnectManager.shareInstance.hasNetworkProvider{
            self.connectState = .connecting
        }
        ConnectManager.shareInstance.setupServerProvider {
            if self.connectState != .connecting{
                self.connectState = .connecting
            }
            let netContent = try! Reachability()
            if netContent.connection == .unavailable {
                ZKProgressHUD.showInfo("No network connection.")
                ShowLog("[tunnel] No network connection.")
                self.connectState = .disConnected
                return
            }
            var serverTestLists:[SeverModel] = []
            if self.choiceServerIndex == 0 {
                serverTestLists = serverLists
            }
            else{
                serverTestLists = [serverLists[self.choiceServerIndex - 1]]
            }
            SpeedTestManager.shareInstance.testServerList(serverTestLists) { [weak self] serversSorted in
                if serversSorted.count > 0 {
                    self?.serverRandom = serversSorted[Int(arc4random()) % serversSorted.count]
                    if isInForeGround {
                        ConnectManager.shareInstance.connectServer(self!.serverRandom!)
                    }
                    else{
                        ShowLog("enter background, cannot connect ")
                        self?.connectState = .disConnected
                    }
                }
                else{
                    self?.connectState = .disConnected
                    ZKProgressHUD.showInfo("Connection failed. Try again.")
                }
            }
        }
    }
    
    private func disconnectServer(){
        self.connectState = .disConnecting
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if isInForeGround{
                ConnectManager.shareInstance.disconnectServer()
            }
            else{
                ShowLog("enter background, cannot disconnect ")
                self.connectState = .connected
            }
        }
    }
    
    private func setConnectManagerHandle(){
        ConnectManager.shareInstance.connectStateChangeHandle = { [self] connectS in
            switch connectS {
            case .disConnected:
                if !self.isServerListsBackReconnect {
                    if ConnectManager.shareInstance.hasConnectFirst{
                        self.connectState = .disConnected
                        self.showResultVC(false)
                    }
                    else{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            ConnectManager.shareInstance.hasConnectFirst = true
                        }
                    }
                }
                else {
                    self.isServerListsBackReconnect = false
                    self.connectServer()
                }
            case .connected:
                self.connectState = .connected
                showResultVC()
                
            case .noNetwork:
                self.connectState = .disConnected
                ZKProgressHUD.showInfo("No network connection.")
            case .error:
                self.connectState = .disConnected
                ZKProgressHUD.showInfo("Connection failed. Try again.")
            
            default:
                break
            }
        }
    }
    
    //连接成功状态
    private func showConnected(){
        connectingAnimationView.stop()
        connectingAnimationView.isHidden = true
        disconnectingAnimationView.isHidden = false
        disconnectingAnimationView.stop()
        
        imgBG.image = UIImage(named: "img_main_yellow")
        countryBG.image = UIImage(named: "img_country_yellow")
        logoLab.textColor = UIColor(rgb: 0x333333)
        selCountryLab.textColor = UIColor(rgb: 0x333333)
        selImg.image = UIImage(named: "icon_go_black")
        
        settingBtn.setImage(UIImage(named: "icon_setting_yellow"), for: .normal)
        connectBtn.setImage(UIImage(named: "icon_btn_yellow"), for: .normal)
        stateLab.text = "Disconnect"
        stateLab.textColor = UIColor(rgb: 0x92654C)
        
        changeConnectBtnAni(false)
        changeSpeedByte(true)
        startSpeedTest()
    }
    
    //断开连接状态
    private func showDisconnected(){
        connectingAnimationView.stop()
        connectingAnimationView.isHidden = false
        disconnectingAnimationView.isHidden = true
        disconnectingAnimationView.stop()
        
        imgBG.image = UIImage(named: "img_main_bg")
        settingBtn.setImage(UIImage(named: "icon_setting"), for: .normal)
        countryBG.image = UIImage(named: "img_country_bg")
        logoLab.textColor = .white
        selCountryLab.textColor = .white
        selImg.image = UIImage(named: "icon_go_right")
        
        connectBtn.setImage(UIImage(named: "icon_btn_blue"), for: .normal)
        stateLab.text = "Connect"
        stateLab.textColor = .white
        
        changeConnectBtnAni(false)
        changeSpeedByte(false)
        stopSpeedTest()
    }
    
    //连接中
    private func showConnecting(){
        connectingAnimationView.play()
        connectingAnimationView.isHidden = false
        disconnectingAnimationView.isHidden = true
        disconnectingAnimationView.stop()
        
        imgBG.image = UIImage(named: "img_main_bg")
        countryBG.image = UIImage(named: "img_country_bg")
        logoLab.textColor = .white
        selCountryLab.textColor = .white
        selImg.image = UIImage(named: "icon_go_right")
        
        settingBtn.setImage(UIImage(named: "icon_setting"), for: .normal)
        connectBtn.setImage(UIImage(named: "icon_btn_blueBG"), for: .normal)
        stateLab.text = "Connecting"
        stateLab.textColor = .white
        
        changeConnectBtnAni(true)
    }
    
    //断链中
    private func showDisconnecting(){
        connectingAnimationView.stop()
        connectingAnimationView.isHidden = true
        disconnectingAnimationView.isHidden = false
        disconnectingAnimationView.play()
        
        imgBG.image = UIImage(named: "img_main_yellow")
        countryBG.image = UIImage(named: "img_country_yellow")
        logoLab.textColor = UIColor(rgb: 0x333333)
        selCountryLab.textColor = UIColor(rgb: 0x333333)
        selImg.image = UIImage(named: "icon_go_black")
        settingBtn.setImage(UIImage(named: "icon_setting_yellow"), for: .normal)
        connectBtn.setImage(UIImage(named: "icon_btn_yellowBG"), for: .normal)
        stateLab.text = "Disconnecting"
        stateLab.textColor = UIColor(rgb: 0x92654C)
        
        changeConnectBtnAni(true)
    }
    
    lazy var downAniView: AnimationView = {
        let animationView = AnimationView(name: "downloadAni")
        animationView.frame = CGRect(x: downLine.frame.origin.x, y: downLine.frame.origin.y, width: downLine.frame.size.width, height: 15)
        animationView.loopMode = .loop
        animationView.isHidden = true
        return animationView
    }()
    
    lazy var upAniView: AnimationView = {
        let animationView = AnimationView(name: "uploadAni")
        animationView.frame = CGRect(x: upLine.frame.origin.x, y: upLine.frame.origin.y, width: upLine.frame.size.width, height: 15)
        animationView.loopMode = .loop
        animationView.isHidden = true
        return animationView
    }()
    
    lazy var rotateAni:CABasicAnimation = {
        let ani = CABasicAnimation(keyPath: "transform.rotation.z")
        ani.fromValue = 0
        ani.toValue = Double.pi * 2
        ani.repeatCount = 999
        ani.duration = 1
        return ani
    }()
    
    private func changeConnectBtnAni(_ isshow:Bool){
        if isshow{
            self.connectingImg.isHidden = false
            self.connectingImg.layer.add(rotateAni, forKey: "rotateAni")
        }
        else{
            self.connectingImg.isHidden = true
            self.connectingImg.layer.removeAllAnimations()
        }
    }
    
    private func changeSpeedByte(_ isConnected:Bool){
        if isConnected{
            downLine.isHidden = true
            upLine.isHidden = true
            upAniView.isHidden = false
            upAniView.play()
            downAniView.isHidden = false
            downAniView.play()
        }
        else{
            downLine.isHidden = false
            upLine.isHidden = false
            upAniView.isHidden = true
            upAniView.stop()
            downAniView.isHidden = true
            downAniView.stop()
        }
    }
    
    private func startSpeedTest() {
        CheckSpeedUnit.shared().networkSpeedCallback = { downloadString, uploadString, totalSpeed, totalSpeedString in
            let downArr = downloadString.components(separatedBy: " ")
            let upArr = uploadString.components(separatedBy: " ")
            self.downSpeedLab.text = downArr.first
            self.upSpeedLab.text = upArr.first
            if downArr.count > 1{
                self.downUnitLab.text = downArr[1]
            }
            if upArr.count > 1 {
                self.upUnitLab.text = upArr[1]
            }
        }
        CheckSpeedUnit.shared().startMonitor()
    }
    
    func stopSpeedTest() {
        CheckSpeedUnit.shared().stopMonitor()
        self.downSpeedLab.text = "0.0"
        self.upSpeedLab.text = "0.0"
        self.downUnitLab.text = "Mb/s"
        self.upUnitLab.text = "Mb/s"
    }
    
    //跳转结果页
    private func showResultVC(_ isSuccess:Bool = true){
        let vc = MainStoryBoard.instantiateViewController(withIdentifier: "ResultPageViewController") as! ResultPageViewController
        vc.isSuccess = isSuccess
        vc.clickHandle = { [weak self] in
            if isSuccess{
                self?.choiceCountry()
            }
            else{
                self?.connectServer()
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func btnFunctionClick(sender:UIButton){
        closeSettingView()
        
        switch sender.tag {
        case 0:
            let urlStr = "itms-apps://itunes.apple.com/app/id00000000?action=write-review"
            UIApplication.shared.open(URL(string: urlStr)!, options: [:])
        case 1:
            let params = [
                UIImage(named: "sharelogo")!,
                URL(string: "https://apps.apple.com/us/app/id00000000")!
            ] as [Any]
            let activity = UIActivityViewController(activityItems: params, applicationActivities: nil)
            present(activity, animated: true, completion: nil)
        case 2:
            let vc = RullsViewController.init()
            self.navigationController?.pushViewController(vc, animated: true)
        case 3:
            let vc = RullsViewController.init()
            vc.isTerms = false
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
