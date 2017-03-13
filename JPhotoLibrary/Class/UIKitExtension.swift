//
//  UIKitExtension.swift
//  JPhotoLibrary
//
//  Created by AidenLance on 2017/3/6.
//  Copyright © 2017年 AidenLance. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    /// cropRect 移动坐标并裁剪图片 默认nil target 裁剪的大小
    func cropImage(cropRect:CGRect? = nil, targetSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.main.scale)
        if cropRect != nil {
            let newCGImage = self.cgImage?.cropping(to: cropRect!)
            guard newCGImage != nil else{
                return nil
            }
            let newImage = UIImage.init(cgImage: newCGImage!)
            newImage.draw(in: CGRect.init(origin: CGPoint.zero, size: targetSize))
        } else {
            self.draw(in: CGRect.init(origin: CGPoint.zero, size: targetSize))
        }
        defer {
            UIGraphicsEndImageContext()
        }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func calculateSize() -> CGSize {
        switch self.imageOrientation {
        case .up:
            return CGSize.init(width: screenWidth, height: self.size.height*screenWidth/self.size.width)
        default:
            return CGSize.zero
        }
    }
}

extension UIImageView {

}





