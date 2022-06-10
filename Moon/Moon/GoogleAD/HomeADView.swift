//
//  GadHomeView.swift
//  Moon
//
//  Created by ZY on 2022/6/8.
//

import UIKit
import GoogleMobileAds
import SnapKit

class HomeADView: GADNativeAdView {
    override var nativeAd: GADNativeAd? {
        didSet {
            guard let nativeAd = nativeAd else { return }
            (iconView as? UIImageView)?.image = nativeAd.icon?.image
            (headlineView as? UILabel)?.text = nativeAd.headline
            (bodyView as? UILabel)?.text = nativeAd.body
            (callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = true
        self.isHidden = true
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.borderColor = UIColor(rgb: 0xeeeeee).cgColor
        self.layer.borderWidth = 1
        
        addSubview(iconImgView)
        addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(iconImgView.snp.right).offset(10)
            make.top.equalTo(15)
            make.right.lessThanOrEqualTo(-125)
        }
        addSubview(adFlag)
        adFlag.snp.makeConstraints { make in
            make.left.equalTo(titleLab.snp.right).offset(5)
            make.centerY.equalTo(titleLab)
            make.size.equalTo(CGSize(width: 25, height: 14))
        }
        addSubview(detailLab)
        detailLab.snp.makeConstraints { make in
            make.left.equalTo(titleLab)
            make.top.equalTo(titleLab.snp.bottom).offset(10)
            make.right.lessThanOrEqualTo(-95)
        }
        addSubview(actionBtn)
        actionBtn.snp.makeConstraints { make in
            make.top.equalTo(12)
            make.right.equalTo(-10)
            make.size.equalTo(CGSize(width: 84, height: 34))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //app icon
    private lazy var iconImgView:UIImageView = {
        let iconImg = UIImageView()
        iconImg.contentMode = .scaleAspectFill
        iconImg.layer.cornerRadius = 10
        iconImg.clipsToBounds = true
        iconImg.frame = CGRect(x: 10, y: 10, width: 48, height: 48)
        iconView = iconImg
        return iconImg
    }()
    
    private lazy var titleLab:UILabel = {
        let adTitle = UILabel()
        adTitle.textColor = UIColor(rgb: 0x333333)
        adTitle.font = UIFont.systemFont(ofSize: 14)
        headlineView = adTitle
        return adTitle
    }()
        
    private lazy var adFlag:UILabel = {
        let adflag = UILabel()
        adflag.backgroundColor = UIColor(rgb: 0x43A3D7)
        adflag.textColor = .white
        adflag.font = UIFont.systemFont(ofSize: 10)
        adflag.text = "AD"
        adflag.textAlignment = .center
        adflag.clipsToBounds = true
        adflag.layer.cornerRadius = 2
       
        return adflag
    }()
        
    private lazy var detailLab:UILabel = {
        let adDetail = UILabel()
        adDetail.textColor = UIColor(rgb: 0x666666)
        adDetail.font = UIFont.systemFont(ofSize: 12)
        bodyView = adDetail
        
        return adDetail
    }()
    
    private lazy var actionBtn:UIButton = {
        let adAction = UIButton(type: .custom)
        adAction.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        adAction.backgroundColor = UIColor(rgb: 0x006CFF)
        adAction.layer.cornerRadius = 17
        adAction.setTitleColor(.white, for: .normal)
        callToActionView = adAction
        return adAction
    }()
}
