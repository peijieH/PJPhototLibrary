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

let cellID = "AlbumListID"

class AlbumListViewController: UIViewController {

    override func viewDidLoad() {
        self.navigationController?.navigationBar.barTintColor = UIColor.init(white: 0.1, alpha: 0.3)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = .white
        let rightBarItem = UIBarButtonItem.init(title: "取消", style: .plain, target: self, action: #selector(dismissNavVC))
        self.navigationItem.rightBarButtonItem = rightBarItem
        let albumTableView = AlbumListView.init()
        albumTableView.delegate = self
        self.view.addSubview(albumTableView)
    }
    func dismissNavVC() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

class AlbumListView: UITableView {
    let photoDataSource = PhotoDataSource.init()
    convenience init() {
        self.init(frame: ConstantValue.screenBounds, style: .plain)
        self.dataSource = self
    }
}

extension AlbumListView: UITableViewDataSource {
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            var cell = tableView.dequeueReusableCell(withIdentifier: cellID)
            if cell == nil {
                cell = UITableViewCell.init(style: .value1, reuseIdentifier: cellID)
            }
            cell?.textLabel?.text = photoDataSource.allCollectionArray[indexPath.row].localizedTitle
            
            cell?.detailTextLabel?.text = imageCount(collection: photoDataSource.allCollectionArray[indexPath.row]).description
            collectionLastImage(collection: photoDataSource.allCollectionArray[indexPath.row], imageQuality: .fastFormat) {
                image in cell?.imageView?.image = image
            }
            return cell!
        }
    
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return photoDataSource.allCollectionArray.count
        }
}

extension AlbumListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let albumCollectionViewController = AlbumCollectionViewController.init()
        let tempCollectionData = (tableView as! AlbumListView).photoDataSource.allCollectionArray[indexPath.row]
        albumCollectionViewController.assetCollectionArray = PHAsset.fetchAssets(in: tempCollectionData, options: nil)
        self.navigationController?.pushViewController(albumCollectionViewController, animated: true)
    }
}








