//
//  PhotoKit.swift
//  JPhotoLibrary
//
//  Created by Macx on 16/12/27.
//  Copyright © 2016年 AidenLance. All rights reserved.
//

import Foundation
import Photos


// MARK: cell size
let thumbnailWidth = (UIScreen.main.bounds.size.width - 6)/4
let thumbnailSize = CGSize.init(width: thumbnailWidth, height: thumbnailWidth)

struct ImageSize {
    static var thumbnailSize: CGSize{
//            return CGSize.init(width: thumbnailWidth * UIScreen.main.scale, height: thumbnailWidth*PHImageManagerMaximumSize.height/PHImageManagerMaximumSize.width * UIScreen.main.scale)
            return CGSize.init(width: thumbnailWidth * UIScreen.main.scale, height: thumbnailWidth * UIScreen.main.scale)
    }
    
    static var screenSize: CGSize = CGSize.init(width: ConstantValue.screenWidth, height: ConstantValue.screenHeight)
    
}

class LibAuthorization {
    class func authorizedAction(parentVC: UIViewController) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            let albumVC = AlbumListViewController.init()
            let navVC = UINavigationController.init(rootViewController: albumVC)
            parentVC.present(navVC, animated: true, completion: nil)
        case .denied, .restricted:
            alertView(parentVC: parentVC, title: "访问相册", message: "无权限访问")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                authorizedAction(parentVC: parentVC)
            })
        }
    }
}

class PhotoDataSource {
    let allCollectionArray = allCollectionData()
    
}

func allCollectionData() -> [PHAssetCollection] {
    var allSmartCollectionArray: [PHAssetCollection] = []
    PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil).enumerateObjects({ (assetCollection, index, stop) in
        allSmartCollectionArray.append(assetCollection)
    })

    
    PHAssetCollection.fetchTopLevelUserCollections(with: nil).enumerateObjects({ (collectionList, index, stop) in
        if collectionList is PHAssetCollection {
            allSmartCollectionArray.append(collectionList as! PHAssetCollection)
        }
    })

    let allSmartCollectionSortArray: [PHAssetCollection] = allSmartCollectionArray.sorted {
        
        $0.estimatedAssetCount > $1.estimatedAssetCount
    }
    return allSmartCollectionSortArray

}




func collectionImageData(collection: PHAssetCollection) -> [PHAsset]{
    let result = PHAsset.fetchAssets(in: collection, options: nil)
    var assetArray: [PHAsset] = []
    result.enumerateObjects({ (assetObj, index, stop) in
        assetArray.append(assetObj)
    })
    return assetArray
}

func setLibImage(imageAsset: PHAsset, imageQuality: PHImageRequestOptionsDeliveryMode, resultHandler: @escaping (UIImage?) -> Void) {
    let options = PHImageRequestOptions.init()
    options.deliveryMode = imageQuality
    options.normalizedCropRect = CGRect.init(x: 0, y: 0, width: ImageSize.thumbnailSize.width, height: ImageSize.thumbnailSize.height)
    PHImageManager.default().requestImage(for: imageAsset, targetSize: ImageSize.thumbnailSize, contentMode: .default, options: options) { (image, info) in
        resultHandler(image)
    }
}
//load image




//MARK: preheat load image


class AssetManager {
    let cachingImageManager = PHCachingImageManager()
    let options: PHImageRequestOptions
    var cachingAssets: [PHAsset] = []
    
    init() {
        cachingImageManager.allowsCachingHighQualityImages = false
        options = PHImageRequestOptions.init()
        options.deliveryMode = .opportunistic
        options.version = .current
        options.resizeMode = .none


    }

    func getImage(for imageAsset: PHAsset,  resultHandler: @escaping (UIImage?) -> Void) {
        cachingImageManager.requestImage(for: imageAsset, targetSize: ImageSize.thumbnailSize, contentMode: .aspectFill, options: nil) { image, _ in
            resultHandler(image)
        }
    }
    func startLoadThumbnail(for assets: [PHAsset]) {
        cachingImageManager.startCachingImages(for: assets, targetSize: ImageSize.thumbnailSize, contentMode: .aspectFill, options: nil)
    }

    func stopCachingThumbnail(for assets: [PHAsset]) {
        cachingImageManager.stopCachingImages(for: assets, targetSize: ImageSize.thumbnailSize, contentMode: .aspectFill, options: nil)
    }
    func stopCachingImage() {
        cachingImageManager.stopCachingImagesForAllAssets()
        
    }
    
}






func setBrowserImage(imageAsset: PHAsset, imageQuality: PHImageRequestOptionsDeliveryMode, resultHandler: @escaping (UIImage?) -> Void) {
    let options = PHImageRequestOptions.init()
    options.deliveryMode = imageQuality
    PHCachingImageManager.default().requestImage(for: imageAsset, targetSize: ImageSize.screenSize, contentMode: .default, options: options) { (image, info) in
        resultHandler(image)
    }
}




func imageCount(collection: PHAssetCollection) -> Int {
    return PHAsset.fetchAssets(in: collection, options: nil).count
}


func collectionLastImage(collection: PHAssetCollection, imageQuality: PHImageRequestOptionsDeliveryMode, resultHandler: @escaping (UIImage?) -> Void){
    let fetchResult = PHAsset.fetchAssets(in: collection, options: nil).lastObject
    if fetchResult != nil {
        setLibImage(imageAsset: fetchResult!, imageQuality: imageQuality){
            image in resultHandler(image)
        }
    }else {
        resultHandler(nil)
    }
}



