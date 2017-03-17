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


let bottomViewHeight:CGFloat = 44

class AlbumCollectionViewController : UIViewController {
    
    var assetCollectionArray: PHFetchResult<PHAsset>!
    let collectionCellID = "collectionCellID"
    var albumCollectionView: AlbumCollectionView!
    var bottomBar: BottomBarView?
    let assetManager: AssetManager = AssetManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SelectImageCenter.shareManager.initData(collectionCout: (assetCollectionArray.count))
        
        let rightBarItem = UIBarButtonItem.init(title: "取消", style: .plain, target: self, action: #selector(dismissNavVC))
        self.navigationItem.rightBarButtonItem = rightBarItem
        
        albumCollectionView = AlbumCollectionView.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.view.bounds.width, height: self.view.bounds.height - bottomViewHeight)))
        albumCollectionView?.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: collectionCellID)
        albumCollectionView?.delegate = self
        albumCollectionView?.dataSource = self
        
        bottomBar = BottomBarView.init(frame: CGRect.init(origin: CGPoint.init(x: 0, y: self.view.bounds.height - bottomViewHeight), size: CGSize.init(width: ConstantValue.screenWidth, height: bottomViewHeight)))
        
        self.view.addSubview(albumCollectionView!)
        self.view.addSubview(bottomBar!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCellSelectStatusAction(notify:)), name: .UpdateAlbumThumbnailCellData, object: nil)
    }
    
    func dismissNavVC() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    func reloadCellSelectStatusAction (notify: NSNotification) {
        albumCollectionView?.reloadItems(at: [NSIndexPath.init(row: notify.object as! Int, section: 0) as IndexPath])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        albumCollectionView?.scrollToItem(at: NSIndexPath.init(row: (assetCollectionArray?.count)! - 1, section: 0) as IndexPath, at: .bottom, animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        assetManager.stopCachingImage()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UpdateAlbumThumbnailCellData, object: nil)
        SelectImageCenter.shareManager.cleanData()
    }
}

class BottomBarView : UIView {
    var sendBt: UIButton
    let sendBtHeight: CGFloat = 30
    let sendBtWidth: CGFloat = 40
    
    override init(frame: CGRect) {
        sendBt = UIButton.init(frame: CGRect.init(x: frame.width - sendBtWidth - 10, y: 7, width: sendBtWidth, height: sendBtHeight))
        sendBt.setTitle("发送", for: .normal)
        super.init(frame: frame)
        
        sendBt.setTitleColor(UIColor.btTitleSelectColor, for: .normal)
        sendBt.setTitleColor(UIColor.btTitleDisableColor, for: .disabled)
        sendBt.addTarget(self, action: #selector(sendAction(sender:)), for: .touchUpInside)
        
        self.backgroundColor = .white
        self.addSubview(sendBt)
    }
    
    func sendAction(sender: UIButton) {
        sender.isEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AlbumCollectionViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let albumBrowser = BrowserCollectionVC.init()
//        albumBrowser.assetCollectionArray = assetCollectionArray
//        albumBrowser.selectItemIndex = indexPath.row
//        self.navigationController?.pushViewController(albumBrowser, animated: true)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let visiableitem = lroundf(Float(scrollView.contentOffset.y.divided(by: thumbnailWidth)))
//        if visiableitem >= 1 {
//            let preheatAssets:[PHAsset] = [assetCollectionArray![visiableitem*4], assetCollectionArray![visiableitem*4-1], assetCollectionArray![visiableitem*4-2], assetCollectionArray![visiableitem*4-3]]
//            assetManager.startLoadThumbnail(for: preheatAssets)
//        }
        
        let visibleRect = CGRect.init(origin: scrollView.contentOffset, size: scrollView.bounds.size)
        let visibleLayoutAttributes = albumCollectionView.collectionViewLayout.layoutAttributesForElements(in: visibleRect)
        let visibleItems = visibleLayoutAttributes?.map { $0.indexPath.row }
        let max = visibleItems?.max()
        let min = visibleItems?.min()
        guard max != nil else { return }
        if assetCollectionArray.count - 1 - max! > 8 {
            
        }
        
    }
    
    
    
    
    

}
extension AlbumCollectionViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetCollectionArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionCellID, for: indexPath)
        let albumThumbnailCell = cell as! AlbumCollectionViewCell
        albumThumbnailCell.cellImageAsset = assetCollectionArray?[indexPath.row]
        albumThumbnailCell.cellIndex = indexPath.row
        albumThumbnailCell.selectBt.isSelected = SelectImageCenter.shareManager.collectionArray[indexPath.row]
        assetManager.getImage(for: (assetCollectionArray?[indexPath.row])!)
        {
            image in
            if image != nil {
                albumThumbnailCell.contentImage = self.imageResize(image: image!, size: thumbnailSize)
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


class AlbumCollectionView : UICollectionView {
    convenience init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = thumbnailSize
        layout.estimatedItemSize = thumbnailSize
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 0
        self.init(frame: frame, collectionViewLayout: layout)
        self.backgroundColor = UIColor.white
    }

}

class AlbumCollectionViewCell : UICollectionViewCell {
    let contentImageView: UIImageView
    let selectBt: UIButton
    var cellIndex: Int?
    var cellImageAsset: PHAsset?
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
        selectBt = UIButton.init(frame: CGRect.init(origin: CGPoint.init(x: frame.width - 2 - 23, y: 2), size: CGSize.init(width: 23, height: 23)))
        selectBt.setImage(UIImage.init(named: "unSelect"), for: .normal)
        selectBt.setImage(UIImage.init(named: "select"), for: .selected)
        super.init(frame: frame)
        self.contentView.addSubview(contentImageView)
        self.contentView.backgroundColor = UIColor.white
        self.contentView.addSubview(selectBt)
        selectBt.addTarget(self, action: #selector(cellSelectAction(sender:)), for: .touchUpInside)
    }
    
    func cellSelectAction(sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            guard cellIndex != nil, cellImageAsset != nil else {
                fatalError("cellIndex or cellImageAsset is nil")
            }
            SelectImageCenter.shareManager.removeSelectImage(index: cellIndex!, imageAsset: cellImageAsset!)
        } else {
            sender.isSelected = true
            SelectImageCenter.shareManager.addSelectImage(index: cellIndex!, imageAsset: cellImageAsset!)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}














