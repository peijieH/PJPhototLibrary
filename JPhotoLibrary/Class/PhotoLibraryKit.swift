//
//  PhotoKit.swift
//  JPhotoLibrary
//
//  Created by Macx on 16/12/27.
//  Copyright © 2016年 AidenLance. All rights reserved.
//

import Foundation
import Photos


class ShareNavigationControlle {
    static let shareNav = ShareNavigationControlle()
    let nav = UINavigationController.init()
}

class PJPhotoAlbum {
    public static let shareCenter = PJPhotoAlbum()
    let assetManager: AssetManager = AssetManager()
    var selectResult: (([PHAsset]) -> Void)? = nil
    var selectItems: [PHAsset]? = nil {
        didSet {
            callback!()
        }
    }
    var callback: (() -> Void)? = nil
    var count: Int {
        if selectItems != nil {
            return (selectItems?.count)!
        } else {
            return 0
        }
    }
    
    func getImage(for index: Int, resultHandler: @escaping (UIImage?) -> Void) {
        guard selectItems !=  nil else { return }
        assetManager.getImage(for: selectItems![index], resultHandler: resultHandler)
    }
    
    class func authorizedAction(parentVC: UIViewController) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            let albumVC = AlbumListViewController.init()
            ShareNavigationControlle.shareNav.nav.viewControllers = [albumVC]
            parentVC.present(ShareNavigationControlle.shareNav.nav, animated: true, completion: nil)
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
    
    class func getAllPhoto() -> PHFetchResult<PHAsset> {
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return PHAsset.fetchAssets(with: allPhotosOptions)
    }
    
    class func getSamrtAlbums() -> PHFetchResult<PHAssetCollection> {
        return PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
    }
    
    class func getUserCollections() -> PHFetchResult<PHCollection> {
        return PHCollectionList.fetchTopLevelUserCollections(with: nil)
    }
    
    class func getPHAsset(fetchCollection: PHFetchResult<PHCollection>) -> ([String], [PHFetchResult<PHAsset>], [Int]) {
        var sumCollection: [PHFetchResult<PHAsset>] = []
        var sumCollectionName: [String] = []
        var sumCollectionCount: [Int] = []
        fetchCollection.enumerateObjects({ (eachCollection, _, _) in
            guard let tempCollection = eachCollection as? PHAssetCollection
                else { fatalError("error: expected asset collection") }
            
            sumCollection.append(PHAsset.fetchAssets(in: tempCollection, options: nil))
            sumCollectionName.append(tempCollection.localizedTitle ?? "")
            if tempCollection.estimatedAssetCount == NSNotFound {
                sumCollectionCount.append(0)
            } else {
                sumCollectionCount.append(tempCollection.estimatedAssetCount)
            }
            
        })
        return (sumCollectionName, sumCollection, sumCollectionCount)
    }
}

//MARK: preheat load image


class AssetManager {
    
    enum OptionsType {
        case highQuality
        case opportunistic
    }
    
    let cachingImageManager = PHCachingImageManager()
    var options: PHImageRequestOptions?
    var targetSize: CGSize
    
    init(optionsType: OptionsType = .opportunistic, targetSize:CGSize = ImageSize.thumbnailSize) {
        switch optionsType {
        case .opportunistic:
            self.targetSize = targetSize
            options = nil
            cachingImageManager.allowsCachingHighQualityImages = false
        default:
            self.targetSize = PHImageManagerMaximumSize
            options = PHImageRequestOptions.init()
            options?.deliveryMode = .highQualityFormat
            options?.resizeMode = .none
            cachingImageManager.allowsCachingHighQualityImages = true
        }
    }

    func getImage(for imageAsset: PHAsset,  resultHandler: @escaping (UIImage?) -> Void) {
        cachingImageManager.requestImage(for: imageAsset, targetSize: targetSize, contentMode: .aspectFill, options: options) { image, _ in
            resultHandler(image)
        }
    }
    
    func getImageData(for asset: PHAsset, resultHandler: @escaping (Data?) -> Void) {
        cachingImageManager.requestImageData(for: asset, options: options) { (data, _, _, resultInfo) in
            resultHandler(data)
        }
    }
    
    func startLoadThumbnail(for assets: [PHAsset]) {
        cachingImageManager.startCachingImages(for: assets, targetSize: targetSize, contentMode: .aspectFill, options: options)
    }

    func stopCachingThumbnail(for assets: [PHAsset]) {
        cachingImageManager.stopCachingImages(for: assets, targetSize: targetSize, contentMode: .aspectFill, options: options)
    }
    
    func stopCachingImage() {
        cachingImageManager.stopCachingImagesForAllAssets()
        
    }
}





