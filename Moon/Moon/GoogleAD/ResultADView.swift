//
//  GadResultView.swift
//  Moon
//
//  Created by ZY on 2022/6/8.
//


import Foundation
import GoogleMobileAds
import SnapKit

class ResultADView: GADNativeAdView {
    override var nativeAd: GADNativeAd? {
        didSet {
            guard let nativeAd = nativeAd else { return }
            (iconView as? UIImageView)?.image = nativeAd.icon?.image
            (headlineView as? UILabel)?.text = nativeAd.headline
            (bodyView as? UILabel)?.text = nativeAd.body
            (callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
            mediav.mediaContent = nativeAd.mediaContent
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
            make.top.equalTo(21)
            make.right.lessThanOrEqualTo(-45)
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
            make.right.lessThanOrEqualTo(-15)
        }
        addSubview(actionBtn)
        actionBtn.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalTo(-15)
            make.height.equalTo(46)
        }
        addSubview(mediav)
        mediav.snp.makeConstraints { make in
            make.top.equalTo(iconImgView.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.bottom.equalToSuperview().offset(-75)
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
        iconImg.frame = CGRect(x: 15, y: 15, width: 48, height: 48)
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
        adAction.backgroundColor = UIColor(rgb: 0xFF8C00)
        adAction.layer.cornerRadius = 23
        adAction.setTitleColor(.white, for: .normal)
        callToActionView = adAction
        return adAction
    }()
    
    lazy var mediav:GADMediaView = {
        let adm = GADMediaView()
        adm.contentMode = .scaleAspectFill
        adm.clipsToBounds = true
        return adm
    }()
}
