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

class BrowserCollectionVC: UIViewController {
    var selectItemIndex = 0
    var assetCollectionArray: PHFetchResult<PHAsset>?
    let reuseIdentifier = "browserCollectionCellReuseID"
    var browserCollectionView: BrowserCollectionView?
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
        createNavbarView()
        
        
    }
    
    func createNavbarView() {
        let navView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: screenWidth, height: 66))
        navView.backgroundColor = UIColor.init(white: 0.1, alpha: 0.7)
        let backBt = UIButton.init(frame: CGRect.init(origin: CGPoint.init(x: 0, y: 16), size: CGSize.init(width: 44, height: 44)))
        let image = UIImage.init(named: "back_icon")
        backBt.setImage(image, for: .normal)
        backBt.addTarget(self, action: #selector(backPopAction), for: .touchUpInside)
        navView.addSubview(backBt)
        self.view.addSubview(navView)
    }
    func backPopAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLayoutSubviews() {
        browserCollectionView?.scrollToItem(at: IndexPath.init(row: selectItemIndex, section: 0), at: .centeredHorizontally, animated: false)

    }

}

extension BrowserCollectionVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (assetCollectionArray?.count)!
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        let browserCell = cell as! BrowserCollectionCell
        setBrowserImage(imageAsset: (assetCollectionArray?.object(at: indexPath.row))!, imageQuality: .highQualityFormat) { (image) in
            browserCell.image = image!
        }
        return browserCell
    }
    
}

extension BrowserCollectionVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("will display")
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("end display")
    }
}

//MARK:
class BrowserCollectionView: UICollectionView {
    convenience init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout.init()
        layout.scrollDirection = .horizontal
        layout.itemSize = screenBounds.size
        layout.minimumLineSpacing = 0.0
        self.init(frame: frame, collectionViewLayout: layout)
        self.isPagingEnabled = true
    }
    
}

class BrowserCollectionCell: UICollectionViewCell {
    var imageView: UIImageView
    let imageScrollView: UIScrollView
    var image: UIImage {
        set {
            let imageSize = newValue.calculateSize()
            imageView.image = newValue
            imageView.frame = CGRect.init(origin: CGPoint.init(x: 0, y: screenHeight/2-imageSize.height/2), size: imageSize)
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
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.tapGestureAction(tapGesture:)))
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tapGestureAction(tapGesture: UITapGestureRecognizer) {
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





