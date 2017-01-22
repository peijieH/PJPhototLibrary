//
//  PhotoKit.swift
//  JPhotoLibrary
//
//  Created by Macx on 16/12/27.
//  Copyright © 2016年 AidenLance. All rights reserved.
//

import Foundation
import Photos

func allCollectData() -> [PHAssetCollection] {
    var allSmartCollectionArray: [PHAssetCollection] = []
    PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil).enumerateObjects({ (assetCollection, index, stop) in
        allSmartCollectionArray.append(assetCollection)
    })
    var allSmartCollectionSortArray: [PHAssetCollection] = allSmartCollectionArray.sorted {
        $0.estimatedAssetCount > $1.estimatedAssetCount
    }
    
    PHCollectionList.fetchTopLevelUserCollections(with: nil).enumerateObjects({ (collectionList, index, stop) in
        allSmartCollectionSortArray.append(collectionList as! PHAssetCollection)
    })
    for temp in allSmartCollectionSortArray {
        print(temp.localizedTitle!)
    }
    return allSmartCollectionSortArray
}


func collectionImageData(collection: PHAssetCollection) -> [PHAsset]{
    let result = PHAsset.fetchAssets(in: collection, options: nil)
    return result
}
