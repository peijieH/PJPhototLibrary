//
//  AlbumListView.swift
//  JPhotoLibrary
//
//  Created by AidenLance on 2017/1/25.
//  Copyright © 2017年 AidenLance. All rights reserved.
//

import Foundation
import UIKit
import Photos



class AlbumListViewController: UIViewController {
    var photoAsset: [PHFetchResult<PHAsset>]!
    var photoAssetName: [String]!
    var photoPerAssetCount: [Int]!
    let cellID = "AlbumListID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.init(white: 0.1, alpha: 0.3)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = .white
        
        let rightBarItem = UIBarButtonItem.init(title: "取消", style: .plain, target: self, action: #selector(dismissNavVC))
        self.navigationItem.rightBarButtonItem = rightBarItem
        
        let allPhoto = PhotoDataSource.getAllPhoto()
        let (smartPhotoName, smartPhoto, perSmartCount) = PhotoDataSource.getPHAsset(fetchCollection: PhotoDataSource.getSamrtAlbums() as! PHFetchResult<PHCollection>)
        let (userCollectionName, userCollection, perUserCollectionCount) = PhotoDataSource.getPHAsset(fetchCollection: PhotoDataSource.getUserCollections())
        photoAsset = [allPhoto] + smartPhoto + userCollection
        photoAssetName = ["所有照片"] + smartPhotoName + userCollectionName
        photoPerAssetCount = [allPhoto.count] + perSmartCount + perUserCollectionCount
        
        let albumTableView = UITableView.init(frame: self.view.bounds, style: .plain)
        albumTableView.delegate = self
        albumTableView.dataSource = self
        self.view.addSubview(albumTableView)
        
    }
    
    func dismissNavVC() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}


extension AlbumListViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
            if cell == nil {
                cell = UITableViewCell.init(style: .value1, reuseIdentifier: cellID)
            }
            cell?.textLabel?.text = photoAssetName[indexPath.row]
            cell?.detailTextLabel?.text = String(photoPerAssetCount[indexPath.row])
            
            return cell!
        }
    
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return photoAsset.count
        }
}

extension AlbumListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let albumCollectionViewController = AlbumCollectionViewController.init()
        albumCollectionViewController.assetCollectionArray = photoAsset[indexPath.row]
        self.navigationController?.pushViewController(albumCollectionViewController, animated: true)
    }
}








