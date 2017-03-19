//
//  SelectImageCenter.swift
//  JPhotoLibrary
//
//  Created by AidenLance on 2017/3/15.
//  Copyright © 2017年 AidenLance. All rights reserved.
//

import Foundation
import Photos

enum ImageDataType {
    case file
    case data
}

class SelectImageCenter {
    var collectionArray:[Bool] = []
    var selectArray: [PHAsset] = [] {
        willSet {
            UpdateSelectNum(num: newValue.count)
        }
    }
    
    var imageType = ImageDataType.data
    static let shareManager = SelectImageCenter()
    
    func initData(collectionCout: Int) {
        collectionArray = Array.init(repeating: false, count: collectionCout)
    }
    
    func cleanData() {
        collectionArray.removeAll()
        selectArray.removeAll()
    }
    
    func addSelectImage(isNotify: Bool = false, index: Int, imageAsset: PHAsset) {
        collectionArray[index] = true
        selectArray.append(imageAsset)
        if isNotify {
            UpdateAlbumThumbnailCellData(index: index)
        }
    }
    
    func removeSelectImage(isNotify: Bool = false, index: Int, imageAsset: PHAsset) {
        collectionArray[index] = false
        for (indexTemp, valueTemp) in selectArray.enumerated() {
            if valueTemp == imageAsset {
                selectArray.remove(at: indexTemp)
                break
            }
        }
        if isNotify {
            UpdateAlbumThumbnailCellData(index: index)
        }
    }
    
    func sendImageData() {
        
    }
    
    func UpdateAlbumThumbnailCellData(index: Int) {
        NotificationCenter.default.post(name: .UpdateAlbumThumbnailCellData, object: index)
    }
    
    func UpdateSelectNum(num: Int) {
        NotificationCenter.default.post(name: .UpdateSelectNum, object: num)
    }
}

extension NSNotification.Name {
    static let UpdateAlbumThumbnailCellData: NSNotification.Name = NSNotification.Name.init("com.peijie.jphtotolibrary.UpdateAlbumThumbnailCellData")
    static let UpdateSelectNum: NSNotification.Name = NSNotification.Name.init("com.peijie.jphotolibrary.UpdateSelectNum")
    
}




