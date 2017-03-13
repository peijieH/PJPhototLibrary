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
    let collectionCellID = "collectionCellID"
    
    override func viewDidLoad() {
        let rightBarItem = UIBarButtonItem.init(title: "取消", style: .plain, target: self, action: #selector(dismissNavVC))
        self.navigationItem.rightBarButtonItem = rightBarItem
        
        let albumCollectionView = AlbumCollectionView.init()
        albumCollectionView.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: collectionCellID)
        albumCollectionView.delegate = self
        albumCollectionView.dataSource = self
        self.view.addSubview(albumCollectionView)
        
    }
    
    func dismissNavVC() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

}

extension AlbumCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let albumBrowser = BrowserCollectionVC.init()
        albumBrowser.assetCollectionArray = assetCollectionArray
        albumBrowser.selectItemIndex = indexPath.row
        self.navigationController?.pushViewController(albumBrowser, animated: true)
    }
}
extension AlbumCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetCollectionArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellID, for: indexPath)
        setLibImage(imageAsset: (assetCollectionArray?.object(at: indexPath.row))!, imageQuality: .opportunistic) { (image) in
            if image != nil{
                (cell as! AlbumCollectionViewCell).contentImage = self.imageResize(image: image!, size: thumbnailSize)
            }
            
        }
        return cell
    }
    
    func imageResize(image: UIImage, size: CGSize) -> UIImage? {
        let pixelHeight = image.size.height
        let pixelWidth = image.size.width
        let newImage: UIImage?
        if pixelHeight > pixelWidth {
            newImage = image.cropImage(cropRect: CGRect.init(x: 0, y: (pixelHeight - pixelWidth)/2, width: pixelWidth, height: pixelWidth), targetSize: size)
        }else {
            newImage = image.cropImage(cropRect: CGRect.init(x: (pixelWidth - pixelHeight)/2, y: 0, width: pixelHeight, height: pixelHeight), targetSize: size)
        }
        
        return newImage
    }
}


class AlbumCollectionView: UICollectionView {
     convenience init() {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = thumbnailSize
        layout.estimatedItemSize = thumbnailSize
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 0
        self.init(frame: screenBounds, collectionViewLayout: layout)
        self.backgroundColor = UIColor.white
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














