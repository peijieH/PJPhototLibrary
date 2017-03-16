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
    static let originBtFrame = CGRect.init(x: ConstantValue.screenWidth/2 - 40, y: 0, width: 80, height: 44)
    
}

class BrowserCollectionVC: UIViewController {
    var selectItemIndex = 0
    var assetCollectionArray: PHFetchResult<PHAsset>?
    let reuseIdentifier = "browserCollectionCellReuseID"
    var browserCollectionView: BrowserCollectionView?
    var navView: NavView?
    var bottomBarView: BrowserBottomBarView?
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
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
            SelectImageCenter.shareManager.removeSelectImage(index: tempIndex, imageAsset: (assetCollectionArray?[tempIndex])!)
        } else {
            sender.isSelected = true
            SelectImageCenter.shareManager.addSelectImage(index: tempIndex, imageAsset: (assetCollectionArray?[tempIndex])!)
        }

    }

    override func viewDidLayoutSubviews() {
        browserCollectionView?.scrollToItem(at: IndexPath.init(row: selectItemIndex, section: 0), at: .centeredHorizontally, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    /// get visible cell index
    func getVisibleItemIndex() -> Int{
        return Int(lroundf(Float((browserCollectionView?.contentOffset.x)!/ConstantValue.screenWidth)))
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
    var originBt: UIButton
    var sendBt: UIButton
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
        originBt = UIButton.init(frame: AlbumListViewConstantValue.originBtFrame)
        originBt.setTitle("原图", for: .normal)
        originBt.setTitleColor(UIColor.white, for: .normal)
        sendBt = UIButton.init(frame: AlbumListViewConstantValue.sendBtFrame)
        sendBt.setTitle("发送", for: .normal)
        sendBt.setTitleColor(UIColor.btTitleSelectColor, for: .normal)
        super.init(frame: frame)
        self.addSubview(originBt)
        self.addSubview(sendBt)
        self.backgroundColor = UIColor.navViewBackgroundColor
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



extension BrowserCollectionVC: UICollectionViewDataSource,  CollectionViewCellTouchDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (assetCollectionArray?.count)!
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let browserCell = cell as! BrowserCollectionCell
        browserCell.delegate = self
        setBrowserImage(imageAsset: (assetCollectionArray?.object(at: indexPath.row))!, imageQuality: .highQualityFormat) { (image) in
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

protocol CollectionViewCellTouchDelegate {
    func touchTheView()
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





