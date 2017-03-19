//
//  AlbumBrowser.swift
//  JPhotoLibrary
//
//  Created by AidenLance on 2017/3/6.
//  Copyright © 2017年 AidenLance. All rights reserved.
//

import Foundation
import UIKit
import Photos

enum ImageScaleValue: CGFloat {
    case defaultScale = 1.0
    case minScale = 0.5
    case maxScale = 2.0
}

struct AlbumListViewConstantValue {
    static let naviHeight: CGFloat = 66
    
    static let backBtFrame: CGRect = CGRect.init(x: 0, y: 16, width: 44, height: 44)
    
    static let selectBtFrame: CGRect = CGRect.init(x: ConstantValue.screenWidth - 44 - 5, y: 16, width: 44, height: 44)
    
    static let browserBottomBarViewFrame = CGRect.init(x: 0, y: ConstantValue.screenHeight - 44, width: ConstantValue.screenWidth, height: 44)
    
    static let NavViewFrame = CGRect.init(x: 0, y: 0, width: ConstantValue.screenWidth, height: AlbumListViewConstantValue.naviHeight)
    
    static let sendBtFrame = CGRect.init(x: ConstantValue.screenWidth - 44 - 10, y: 0, width: 44, height: 44)
    
    static let sendNumFrame = CGRect.init(x: ConstantValue.screenWidth - 44 - 10 - 1 - 30, y: 2, width: 30, height: 40)
    
    static let originBtFrame = CGRect.init(x: ConstantValue.screenWidth/2 - 32, y: 0, width: 55, height: 44)
    
    static let storageFrame = CGRect.init(x: ConstantValue.screenWidth/2 - 32 - 62 , y: 0, width: 30, height: 44)
}

class BrowserCollectionVC: UIViewController {
    var selectItemIndex = 0
    var assetCollectionArray: PHFetchResult<PHAsset>!
    let reuseIdentifier = "browserCollectionCellReuseID"
    
    var browserCollectionView: BrowserCollectionView!
    var navView: NavView!
    var bottomBarView: BrowserBottomBarView!
    
    let assetManager = AssetManager.init(optionsType: .highQuality)
    var lastPreheatRect = CGRect.zero
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        browserCollectionView = BrowserCollectionView.init(frame: self.view.bounds)
        browserCollectionView?.register(BrowserCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        browserCollectionView?.delegate = self
        browserCollectionView?.dataSource = self
        
        self.view.addSubview(browserCollectionView!)
        self.navigationController?.isNavigationBarHidden = true
        
        navView = NavView.init(frame: AlbumListViewConstantValue.NavViewFrame)
        navView?.backBt?.addTarget(self, action: #selector(backPopAction), for: .touchUpInside)
        navView?.selectBt?.addTarget(self, action: #selector(selectImageAction(sender:)), for: .touchUpInside)
        
        bottomBarView = BrowserBottomBarView.init(frame: AlbumListViewConstantValue.browserBottomBarViewFrame)
        
        self.view.addSubview(bottomBarView!)
        self.view.addSubview(navView!)
    }
    
    func backPopAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    func selectImageAction(sender: UIButton) {
        let tempIndex = getVisibleItemIndex()
        if sender.isSelected {
            sender.isSelected = false
            SelectImageCenter.shareManager.removeSelectImage(isNotify: true, index: tempIndex, imageAsset: (assetCollectionArray?[tempIndex])!)
        } else {
            sender.isSelected = true
            SelectImageCenter.shareManager.addSelectImage(isNotify: true, index: tempIndex, imageAsset: (assetCollectionArray?[tempIndex])!)
        }

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateCachingAsset()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard assetCollectionArray.count > 0 else { return }
        browserCollectionView?.scrollToItem(at: IndexPath.init(row: selectItemIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        assetManager.stopCachingImage()
    }
    
    /// get visible cell index
    func getVisibleItemIndex() -> Int{
        return lroundf(Float((browserCollectionView?.contentOffset.x)!/ConstantValue.screenWidth))
    }
}

class NavView : UIView {
    let naviHeight: CGFloat = 66
    var backBt: UIButton?
    var selectBt: UIButton?
    var isShow: Bool = true {
        willSet {
            if newValue {
                UIView.animate(withDuration: 0.1, animations: {
                    self.isHidden = false
                })
            } else {
                UIView.animate(withDuration: 0.1, animations: {
                    self.isHidden = true
                })
            }
        }
    }
    
    override init(frame: CGRect) {
        backBt = UIButton.init(frame: AlbumListViewConstantValue.backBtFrame)
        selectBt = UIButton.init(frame: AlbumListViewConstantValue.selectBtFrame)
        let image = UIImage.init(named: "back")
        backBt?.setImage(image, for: .normal)
        super.init(frame: frame)
        
        selectBt = UIButton.init(frame: AlbumListViewConstantValue.selectBtFrame)
        selectBt?.setImage(UIImage.init(named: "unSelect"), for: .normal)
        selectBt?.setImage(UIImage.init(named: "select"), for: .selected)
        
        self.addSubview(backBt!)
        self.backgroundColor = UIColor.navViewBackgroundColor
        self.addSubview(selectBt!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class BrowserBottomBarView: UIView {
    var originBt: OriginBt!
    var sendBt: UIButton!
    var sendNum: UILabel!
    var storageCount: UILabel!
    var selectOriginDelegate: SelectOriginDataDelegate?
    
    var isShow: Bool = true {
        willSet {
            if newValue {
                UIView.animate(withDuration: 0.1, animations: {
                    self.isHidden = false
                })
            } else {
                UIView.animate(withDuration: 0.1, animations: {
                    self.isHidden = true
                })
            }
        }
    }
    
    override init(frame: CGRect) {
        originBt = OriginBt.init(frame: AlbumListViewConstantValue.originBtFrame)
        originBt.setAttributedTitle(NSAttributedString.init(string: "原图", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.white]), for: .normal)
        originBt.setImage(UIImage.init(named: "unOrigin"), for: .normal)
        originBt.setImage(UIImage.init(named: "origin"), for: .selected)
        
        sendBt = UIButton.init(frame: AlbumListViewConstantValue.sendBtFrame)
        sendBt.setTitle("发送", for: .normal)
        sendBt.setTitleColor(UIColor.btTitleSelectColor, for: .normal)
        
        sendNum = UILabel.init(frame: AlbumListViewConstantValue.sendNumFrame)
        sendNum.textAlignment = .right
        sendNum.textColor = UIColor.btTitleSelectColor
        sendNum.font = UIFont.systemFont(ofSize: 14)
        sendNum.text = String.init(format: "%@", SelectImageCenter.shareManager.selectArray.count == 0 ? "" :  "(" + SelectImageCenter.shareManager.selectArray.count.description + ")")
        
        storageCount = UILabel.init(frame: AlbumListViewConstantValue.storageFrame)
        storageCount.attributedText = NSAttributedString.init(string: "", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.white])
        
        
        super.init(frame: frame)
        self.addSubview(originBt)
        self.addSubview(sendBt)
        self.addSubview(sendNum)
        self.addSubview(storageCount)
        
        self.backgroundColor = UIColor.navViewBackgroundColor
        
        originBt.addTarget(self, action: #selector(originSelectAction(sender:)), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSelectNumAction(notify:)), name: .UpdateSelectNum, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc fileprivate func updateSelectNumAction(notify: NSNotification) {
        self.sendNum.text = String.init(format: "%@", notify.object as! Int == 0 ? "" :  "(" + (notify.object as! Int).description + ")")
    }
    
    func originSelectAction(sender: UIButton) {
        if sender.isSelected {
            sender.isSelected  = false
        } else {
            sender.isSelected = true
        }
        
        guard selectOriginDelegate != nil else { return }
        selectOriginDelegate?.selectOriginData(isSelect: sender.isSelected)
    }
}



extension BrowserCollectionVC : UICollectionViewDataSource,  CollectionViewCellTouchDelegate, SelectOriginDataDelegate {
    //MARK: datasouce
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (assetCollectionArray?.count)!
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let browserCell = cell as! BrowserCollectionCell
        browserCell.delegate = self
        assetManager.getImage(for: assetCollectionArray[indexPath.row]) { image in
            browserCell.image = image!
        }
        return browserCell
    }
    
    //MARK: CollectionViewCellTouchDelegate
    func touchTheView() {
        if let bottomViewTemp = self.bottomBarView, let navViewTmep = self.navView {
            if bottomViewTemp.isShow {
                bottomViewTemp.isShow = false
                navViewTmep.isShow = false
            } else {
                bottomViewTemp.isShow = true
                navViewTmep.isShow = true
            }
        }
    }
    //MARK: select origin date delegate
    func selectOriginData(isSelect: Bool) {
        if isSelect {
            
        } else {
            
        }
    }
    
    
}

protocol CollectionViewCellTouchDelegate {
    func touchTheView()
}

protocol SelectOriginDataDelegate {
    func selectOriginData(isSelect: Bool)
}

extension BrowserCollectionVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = getVisibleItemIndex()
        if SelectImageCenter.shareManager.collectionArray[index] {
            navView?.selectBt?.isSelected = true
        } else {
            navView?.selectBt?.isSelected = false
        }
        
        // asset image caching
        updateCachingAsset()
        
    }
    
    func getImageStorageSize(asset: PHAsset) {
        
    }
    
    
    fileprivate func updateCachingAsset () {
        let visibleRect = CGRect.init(origin: browserCollectionView.contentOffset, size: browserCollectionView.bounds.size)
        let visibleItems = getItems(for: visibleRect)
        
        let prheatRect = visibleRect.insetBy(dx: -2 * visibleRect.width, dy: 0)
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
    
   fileprivate func getItems(for rect: CGRect) -> [Int]?{
        let layoutAttributes = browserCollectionView.collectionViewLayout.layoutAttributesForElements(in: rect)
        return layoutAttributes?.map { $0.indexPath.row }
    }

    
}

//MARK:
class BrowserCollectionView: UICollectionView {
    convenience init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.itemSize = ConstantValue.screenBounds.size
        layout.minimumLineSpacing = 0.0
        self.init(frame: frame, collectionViewLayout: layout)
        self.isPagingEnabled = true
        
    }
    
    
}



class BrowserCollectionCell: UICollectionViewCell {
    var imageView: UIImageView
    let imageScrollView: UIScrollView
    var delegate: CollectionViewCellTouchDelegate?
    var image: UIImage {
        set {
            let imageSize = newValue.calculateSize()
            imageView.image = newValue
            imageView.frame = CGRect.init(origin: CGPoint.init(x: 0, y: ConstantValue.screenHeight/2-imageSize.height/2), size: imageSize)
            imageScrollView.contentSize = imageSize
            imageScrollView.delegate = self
        }
        get {
            return imageView.image!
        }

    }
    override init(frame: CGRect) {
        imageView = UIImageView.init()
        imageView.isUserInteractionEnabled = true
        imageScrollView = UIScrollView.init(frame: CGRect.init(origin: CGPoint.zero, size: frame.size))
        imageScrollView.minimumZoomScale = ImageScaleValue.minScale.rawValue
        imageScrollView.maximumZoomScale = ImageScaleValue.maxScale.rawValue
        super.init(frame: frame)
        imageScrollView.addSubview(imageView)
        self.contentView.addSubview(imageScrollView);
        
        let tapGestureSingle = UITapGestureRecognizer.init(target: self, action: #selector(self.tapGestureSingleAction(tapGesture:)))
        let tapGestureDouble = UITapGestureRecognizer.init(target: self, action: #selector(self.tapGestureDoubleAction(tapGesture:)))
        tapGestureDouble.numberOfTouchesRequired = 1
        tapGestureDouble.numberOfTapsRequired = 2
        tapGestureSingle.require(toFail: tapGestureDouble)
        
        imageView.addGestureRecognizer(tapGestureSingle)
        imageView.addGestureRecognizer(tapGestureDouble)
        imageScrollView.addGestureRecognizer(tapGestureSingle)
        imageScrollView.addGestureRecognizer(tapGestureDouble)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tapGestureSingleAction(tapGesture: UITapGestureRecognizer) {
        guard self.delegate != nil else {
            return
        }
        self.delegate?.touchTheView()
    }
    
    func tapGestureDoubleAction(tapGesture: UITapGestureRecognizer) {
        if imageScrollView.zoomScale != ImageScaleValue.defaultScale.rawValue {
            imageScrollView.setZoomScale(ImageScaleValue.defaultScale.rawValue, animated: true)
        } else {
            imageScrollView.setZoomScale(ImageScaleValue.maxScale.rawValue, animated: true)
        }
    }
}

extension BrowserCollectionCell: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentSize.width > scrollView.bounds.size.width ? scrollView.contentSize.width - scrollView.bounds.size.width : 0.0
        let offsetY = scrollView.contentSize.height > scrollView.bounds.size.height ?
            scrollView.contentSize.height - scrollView.bounds.size.height  : 0.0
        imageView.center = CGPoint.init(x: (scrollView.bounds.size.width + offsetX)*0.5, y: (scrollView.bounds.size.height + offsetY)*0.5)
    }
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        if scale < 1.0 {
            UIView.beginAnimations("bounceAnimation", context: nil)
            scrollView.zoomScale = 1.0
            UIView.commitAnimations()
        }

    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}





