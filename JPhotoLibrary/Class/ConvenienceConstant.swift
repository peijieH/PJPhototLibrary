//
//  ConvenienceConstant.swift
//  JPhotoLibrary
//
//  Created by AidenLance on 2017/1/26.
//  Copyright © 2017年 AidenLance. All rights reserved.
//

import Foundation
import UIKit

struct ConstantValue {
    static let screenBounds = UIScreen.main.bounds
    static let screenWidth = screenBounds.size.width
    static let screenHeight = screenBounds.size.height
}




/// show alert
///
/// - Parameters:
///   - parentVC: parentVC
///   - title: title
///   - message: message
func alertView(parentVC: UIViewController, title: String, message: String){
    let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction.init(title: "好的", style: .default, handler: nil))
    parentVC.present(alertController, animated: true, completion: nil)
    
    
}




