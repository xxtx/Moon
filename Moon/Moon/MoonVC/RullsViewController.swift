//
//  RullsViewController.swift
//  Moon
//
//  Created by ZY on 2022/6/2.
//

import Foundation
import UIKit

class RullsViewController:UIViewController{
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .darkContent
    }
    
    var isTerms = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        
        let backBtn = UIButton(frame: CGRect(x: 0, y: StatusBarH + 5, width: 60, height: 40))
        backBtn.setImage(UIImage(named: "icon_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backClick), for: .touchUpInside)
        self.view.addSubview(backBtn)
        
        let textV = UITextView(frame: CGRect(x: 20, y: 64 + StatusBarH, width: SCREENW - 35, height: SCREENH - BottomBarH - StatusBarH - 64))
        textV.backgroundColor = .white
        textV.isEditable = false
        textV.font = .systemFont(ofSize: 16)
        textV.textColor = UIColor(rgb: 0x555555)
        view.addSubview(textV)
        
        let titleLab = UILabel(frame: CGRect(x: 60, y: StatusBarH + 15, width: 150, height: 20))
        titleLab.textColor = UIColor(rgb: 0x333333)
        titleLab.font = .systemFont(ofSize: 19)
        view.addSubview(titleLab)
        
        if isTerms{
            titleLab.text = "Terms of user"
            textV.text =
"""
The following terms and conditions apply to your use of this website and the software and services we provide to you. The condition is a personal judgment between you and us, of which we are an integral part. Internet users of the service, and all users of the services and features are subject to our articles of user agreement.

You agree with the following:
Do not use the system to send spam, port scan, scan for open proxies or open relays, send opt-in emails, unsolicited emails, or mass-delivery emails of any type or version, even if the emails are ultimately sent from another a server.
Do not launch any popups from our service.
Do not attack or form any other computer or network in any way while using our services.
Hacking, cracking, spreading viruses, fraudulent activity, cyber sabotage, phishing and/or any conduct deemed illegal or unwelcome will be suspended or terminated.
Users are responsible for the correct security configuration of their services and for any damage caused by negligence or exposure of vulnerabilities, intentional or unintentional.

Possible problems：
Actual service coverage, speed, location and quality may vary. Service will attempt to be available at all times, except during limited maintenance and repair periods. However, the service may be unavailable due to various factors beyond our control, including emergencies, failure of third-party services, transmission, equipment or network problems or limitations, interference, signal strength, and may be interrupted, denied, limited or otherwise reduce. We are not responsible for lost, undelivered, delayed or misleading data, messages or pages due to interruptions or performance issues with the Services or communications services or networks (such as T-1 lines or the Internet). We may impose usage or service restrictions, suspend the service, or block certain types of use in our sole discretion to protect users or the service. Network speeds are estimates and do not represent how fast you or the service can send or receive data. Actual network speeds will vary based on configuration, compression, network congestion, and other factors. The accuracy and timeliness of data received is not guaranteed; delays or omissions may occur.
"""
        }
        else{
            titleLab.text = "private policy"
            textV.text =
"""
Data collected
In accordance with applicable law and in order to avoid infringing any Internet service provider, any browsing information, traffic destinations, data content, IP addresses, DNS queries or other similar information that you transmit to our servers in connection with your online activities are encrypted and after clearing Space "session" was closed. That is, we do not collect any information about the websites you visit or any data stored on or transmitted from your device, including any data that applications on your device may transmit over virtual networks.

We will collect the following information:
Speed test data.
Diagnostic information about whether and how network connection attempts fail.
Crash reports, nor any personally identifiable information. These are processed anonymously by third parties, depending on the platform you use.
Information about applications and application versions, allowing our support team to efficiently identify and eliminate technical issues for you.

Conclusion
We collect minimal usage statistics to maintain the quality of our service. While we serve users who increase network speed, we cannot uniquely identify any specific behavior of any user because thousands of users share the same location at the same time to enjoy the Internet, and usage patterns differ from those of thousands of other customers overlap to connect to the same location on the same day. Regarding sensitive data, we have designed our system to explicitly eliminate the storage of sensitive data. We never know how they use our services.

Data of use
We use the collected information for the various purposes described below.

● To provide, maintain, troubleshoot and support our Services. Our use of your information for this purpose is necessary to perform our contractual obligations to you. Examples: use information about how much bandwidth you use and how long you use our services to provide services based on the plan you subscribe to; use threat and device information to determine whether certain items pose a potential security threat; use location information connect you to the nearest and fastest server; and use the usage information to troubleshoot problems you report with our services and to ensure our services are functioning properly.

● Improve our services. We want to provide you with the best service and user experience, so we have a legitimate interest to continuously improve and optimize our services. To this end, we use your information to understand how users interact with our services. Examples: We analyze certain usage, device and diagnostic information to understand general usage trends and user engagement with our Services (for example, investing in technology infrastructure to better serve areas where user demand is growing); we Device and threat information may be used for spam, threat and other scientific research to improve our threat detection capabilities; we review customer feedback to see where we can do better.

● Develop new services. We have a legitimate interest in using your information to plan and develop new services. For example, we may use customer feedback to understand what new services users might want.

● Marketing and promotion of our Services. We may use your information to provide, measure, personalize and enhance our advertising and marketing based on our legitimate interest in providing services that may be of interest to you. Examples: We may use information such as who or what referred you to our services to understand how our advertising is performing; we may use information to manage promotions such as sweepstakes and referral programs. Our products do not use your web browsing activity for these purposes, and we do not keep any records of what you browse or access through a server connection.

● Obey the law. We use your information internally as required by applicable law, legal process or regulation.

Data Security
We are committed to protecting our users' personal data as we take a variety of technical and organizational measures to ensure that Space uses exceptionally strong safeguards to protect the privacy of all our records, including your personal data. We implement physical, business and technical security measures. These robust protections are designed to prevent unauthorized access, disclosure, loss, theft, copying, use or modification of your personal data.

Policy changes
Our Privacy Policy may change from time to time. We will not reduce your rights under this Privacy Policy without your express consent. We will post any privacy policy changes on this page, and if the changes are material, we will provide a more prominent notice.

Contact us
If you have any questions about privacy while using the app, or about our practices, please contact us by email: xxxxxxxxxx.com

"""
        }
    }
    
    
    @objc func backClick(){
        self.navigationController?.popViewController(animated: true)
    }
}
