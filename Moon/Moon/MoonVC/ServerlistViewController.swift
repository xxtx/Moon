//
//  ServerlistViewController.swift
//  Moon
//
//  Created by ZY on 2022/6/2.
//

import Foundation
import UIKit

class ServerlistViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .darkContent
    }
    
    var connectState:ConnectState?
    var selectIndex:Int = 0
    var selcctHandle:((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.view.backgroundColor = UIColor(rgb: 0xf9f9f9)
        let backBtn = UIButton(frame: CGRect(x: 0, y: StatusBarH + 5, width: 60, height: 40))
        backBtn.setImage(UIImage(named: "icon_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        self.view.addSubview(backBtn)
        
        let tableView = UITableView(frame: CGRect(x: 0, y: StatusBarH + 60, width: SCREENW, height: SCREENH - StatusBarH - BottomBarH - 60))
        tableView.backgroundColor = UIColor(rgb: 0xf9f9f9)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)
        
        tableView.register(serverListItem.self, forCellReuseIdentifier: "serverListItem")
    }
    
    @objc func backClick(){
        GoogleFBLog.logEvent(.S2)
        self.navigationController?.popViewController(animated: true)
        NotificationCenter.default.post(name: notiNameShowBackAD, object: nil)
    }
    
    ///tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serverLists.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 88
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "serverListItem", for: indexPath) as! serverListItem
        if indexPath.row == 0{
            cell.countryImg.image = UIImage(named: "countrymoon")
            cell.countryLab.text = "Smart Server"
        }
        else{
            cell.countryImg.image = UIImage(named: serverLists[indexPath.row - 1].serverIcon)
            cell.countryLab.text = serverLists[indexPath.row - 1].serverCountry
        }
        if selectIndex == indexPath.row, connectState == .connected{
            cell.selectImg.image = UIImage(named: "selectServer")
        }
        else{
            cell.selectImg.image = UIImage(named: "disselectServer")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if connectState == .connected , selectIndex == indexPath.row {return}
        self.selcctHandle?(indexPath.row)
        self.navigationController?.popViewController(animated: true)
    }
}


class serverListItem:UITableViewCell{
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var countryImg:UIImageView = {
        let imgv = UIImageView(frame: CGRect(x: 16, y: 14, width: 36, height: 36))
        return imgv
    }()
    
    lazy var countryLab:UILabel = {
        let lab = UILabel(frame: CGRect(x: 68, y: 22, width: 220, height: 20))
        lab.font = UIFont.systemFont(ofSize: 16)
        lab.textColor = UIColor(rgb: 0x333333)
        return lab
    }()
    
    lazy var selectImg:UIImageView = {
        let imgv = UIImageView(frame: CGRect(x: SCREENW - 80, y: 20, width: 24, height: 24))
        return imgv
    }()
    
    lazy var contentwhiteView:UIView = {
        let view = UIView(frame: CGRect(x: 20, y: 12, width: SCREENW - 40, height: 64))
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        return view
    }()
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundColor = UIColor(rgb: 0xf9f9f9)
        self.selectionStyle = .none
        
        self.addSubview(contentwhiteView)
        contentwhiteView.addSubview(countryImg)
        contentwhiteView.addSubview(countryLab)
        contentwhiteView.addSubview(selectImg)
    }
}
