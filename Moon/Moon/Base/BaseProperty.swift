//
//  BaseProperty.swift
//  Moon
//
//  Created by ZY on 2022/5/31.
//

import Foundation
import UIKit


var inForeGround = true              //是否在前台

let MainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
let MainScene = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate

let SCREENW:CGFloat = UIScreen.main.bounds.size.width
let SCREENH:CGFloat = UIScreen.main.bounds.size.height
let StatusBarH:CGFloat = isFullScreenPhone() ? 44 : 20
let BottomBarH:CGFloat = isFullScreenPhone() ? 40 : 0
let NavigationH:CGFloat = StatusBarH + 44

let isFullScreenPhone = { () -> Bool in
    let screenSize = UIScreen.main.bounds.size
    let ratio  = Int(screenSize.width/screenSize.height * 100.0)
    if ratio == 216 || ratio == 46 {
        return true
    }
    return false
}

func ShowLog(_ logStr:String){
    #if DEBUG
    NSLog("[Moon] \(logStr)")
    #else
    #endif
}


extension UIColor {
    convenience init(rgb: UInt, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0, green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0, blue: CGFloat(rgb & 0x0000FF) / 255.0, alpha: alpha)
    }
}

//func STUserRegion()->String{
//    if let region = UserDefaults.standard.object(forKey: "STUserRegion") as? String{
//        return region
//    }
//    var region = ""
//    let locale = Locale.current
//    if let range = locale.identifier.range(of: "_") {
//        region = String(locale.identifier[range.upperBound..<locale.identifier.endIndex])
//        UserDefaults.standard.set(region, forKey: "STUserRegion")
//    }
//    return region
//}


extension UIImage {
    static func gradualImage(size: CGSize = CGSize(width: 1, height: 1), start:CGPoint = CGPoint(x: 0, y: 0), end:CGPoint = CGPoint(x: -1, y: 0), colors: [UIColor]) -> UIImage {
        if colors.isEmpty {
            return colorimage(from: .white)
        }
        UIGraphicsBeginImageContextWithOptions(size, true, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        
        let colorSpace = colors.last!.cgColor.colorSpace
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors.map({ return $0.cgColor }) as CFArray, locations: nil)

        let startT = start
        let endT = CGPoint(x: (end.x < 0 ? size.width : end.x), y: end.y)

        context?.drawLinearGradient(gradient!, start: startT, end: endT, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        context?.restoreGState()
        UIGraphicsEndPDFContext()
        return image!
    }
    
    static func colorimage(from color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        let image = UIGraphicsImageRenderer(size: size).image { context in
            context.cgContext.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        return image
    }
}
