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
    var lastPreheatRect = CGRect.zero
    
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
        guard assetCollectionArray.count > 0 else {
            return
        }
        albumCollectionView?.scrollToItem(at: NSIndexPath.init(row: (assetCollectionArray?.count)! - 1, section: 0) as IndexPath, at: .bottom, animated: false)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachingAsset()
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
    var sendBt: UIButton!
    var sendNum: UILabel!
    let sendBtHeight: CGFloat = 30
    let sendBtWidth: CGFloat = 40
    
    override init(frame: CGRect) {
        sendBt = UIButton.init(frame: CGRect.init(x: frame.width - sendBtWidth - 10, y: 7, width: sendBtWidth, height: sendBtHeight))
        sendBt.setTitle("发送", for: .normal)
        super.init(frame: frame)
        
        sendBt.setTitleColor(UIColor.btTitleSelectColor, for: .normal)
        sendBt.setTitleColor(UIColor.btTitleDisableColor, for: .disabled)
        sendBt.addTarget(self, action: #selector(sendAction(sender:)), for: .touchUpInside)
        
        sendNum = UILabel.init(frame: CGRect.init(x: frame.width - sendBtWidth - 10 - 3 - 60, y: 8, width: 60, height: sendBtHeight - 5))
        sendNum.textAlignment = .right
        sendNum.textColor = UIColor.btTitleSelectColor
        sendNum.font = UIFont.systemFont(ofSize: 14)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSendNumAction(notify:)), name: .UpdateSelectNum, object: nil)
        
        self.backgroundColor = .white
        self.addSubview(sendBt)
        self.addSubview(sendNum)
        
    }
    
    @objc fileprivate func updateSendNumAction(notify: NSNotification) {
        self.sendNum.text = String.init(format: "%@", notify.object as! Int == 0 ? "" :  "(" + (notify.object as! Int).description + ")")
    }
    
    func sendAction(sender: UIButton) {
        sender.isEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

let preheatCount = 2*4

extension AlbumCollectionViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let albumBrowser = BrowserCollectionVC.init()
        albumBrowser.assetCollectionArray = assetCollectionArray
        albumBrowser.selectItemIndex = indexPath.row
        self.navigationController?.pushViewController(albumBrowser, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachingAsset()
    }
    
    func updateCachingAsset () {
        let visibleRect = CGRect.init(origin: albumCollectionView.contentOffset, size: albumCollectionView.bounds.size)
        let visibleItems = getItems(for: visibleRect)
        
        let prheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        let preheatItems = getItems(for: prheatRect)
        
        let lastPreheat = getItems(for: lastPreheatRect)
        
        let visibleSet = Set(visibleItems!)
        let preheatSet = Set(preheatItems!)
        let lastPreheatSet = Set(lastPreheat!)
        let new = Array(preheatSet.subtracting(lastPreheatSet))
        let old = Array(lastPreheatSet.subtracting(visibleSet).subtracting(lastPreheatSet.subtracting(preheatSet)))
        guard new.min() != lastPreheatSet.min() else { return }
        let newAsset = new.flatMap { temp in assetCollectionArray[temp] }
        let oldAsset = old.flatMap { temp in assetCollectionArray[temp] }
        
        assetManager.stopCachingThumbnail(for: oldAsset)
        assetManager.startLoadThumbnail(for: newAsset)
        lastPreheatRect = prheatRect

    }
    
    func getItems(for rect: CGRect) -> [Int]?{
        let layoutAttributes = albumCollectionView.collectionViewLayout.layoutAttributesForElements(in: rect)
        return layoutAttributes?.map { $0.indexPath.row }
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
                albumThumbnailCell.contentImage = image
            }
        }
        return cell
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
        
        contentImageView = UIImageView.init()
        contentImageView.contentMode = .scaleAspectFill
        contentImageView.clipsToBounds = true
        contentImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let widthConstraint = NSLayoutConstraint.init(item: contentImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: thumbnailSize.width)
        let heightConstraint = NSLayoutConstraint.init(item: contentImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: thumbnailSize.height)
        contentImageView.addConstraints([widthConstraint, heightConstraint])
        
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















