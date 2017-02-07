//
//  AlbumCollectionView.swift
//  JPhotoLibrary
//
//  Created by AidenLance on 2017/2/6.
//  Copyright © 2017年 AidenLance. All rights reserved.
//

import Foundation
import UIKit
import Photos



class AlbumCollectionViewController: UIViewController {
    var assetCollectionArray: PHFetchResult<PHAsset>?
    override func viewDidLoad() {
        let rightBarItem = UIBarButtonItem.init(title: "取消", style: .plain, target: self, action: #selector(dismissNavVC))
        self.navigationItem.rightBarButtonItem = rightBarItem
        
        let albumCollectionView = AlbumCollectionView.init(assetCollection: self.assetCollectionArray)
        self.view.addSubview(albumCollectionView)
        
    }
    func showCollectionImageDetail() {
        
    }
    func dismissNavVC() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

}

class AlbumCollectionView: UICollectionView {
    let collectionCellID = "collectionCellID"
    var assetCollection: PHFetchResult<PHAsset>?
     convenience init(assetCollection: PHFetchResult<PHAsset>?) {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = thumbnailSize
        layout.estimatedItemSize = thumbnailSize
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 0
        self.init(frame: screenBounds, collectionViewLayout: layout)
        self.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: collectionCellID)
        self.delegate = self
        self.dataSource = self
        self.assetCollection = assetCollection
        self.backgroundColor = UIColor.white
    }

}

extension AlbumCollectionView {
}

extension AlbumCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageDetailView = ImageDetailView.init(frame: CGRect.zero)
        setLibImage(imageAsset: (assetCollection?.object(at: indexPath.row))!, imageQuality: .highQualityFormat) { (image) in
            imageDetailView.detailImage = image
        }
        self.addSubview(imageDetailView)
        UIView.animate(withDuration: 2) {
            imageDetailView.frame.size = screenBounds.size
        }
    }
}

extension AlbumCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetCollection?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellID, for: indexPath)
        setLibImage(imageAsset: (assetCollection?.object(at: indexPath.row))!, imageQuality: .highQualityFormat) { (image) in
            (cell as! AlbumCollectionViewCell).contentImage = image
        }
        
        return cell
    }
}

class AlbumCollectionViewCell: UICollectionViewCell {
    let contentImageView: UIImageView
    var contentImage: UIImage? {
        set {
            self.contentImageView.image = newValue
        }
        get {
            return self.contentImageView.image
        }
    }
    override init(frame: CGRect) {
        let thumbnailFrame = CGRect.init(origin: CGPoint.init(x: 0, y: 0), size: thumbnailSize)
        contentImageView = UIImageView.init(frame: thumbnailFrame)
        super.init(frame: frame)
        self.contentView.addSubview(contentImageView)
        self.contentView.backgroundColor = UIColor.white

    
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ImageDetailView: UIView {
    let imageView: UIImageView
    var detailImage: UIImage? {
        get {
            return self.imageView.image
        }
        set {
            self.imageView.image = newValue
        }
    }
    override init(frame: CGRect) {
        self.imageView = UIImageView.init(frame: screenBounds)
        super.init(frame: frame)
        self.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}













