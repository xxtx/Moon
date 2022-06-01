//
//  BaseNavigationController.swift
//  Moon
//
//  Created by ZY on 2022/5/30.
//

import Foundation
import UIKit

class BaseNavigationController: UINavigationController {
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
