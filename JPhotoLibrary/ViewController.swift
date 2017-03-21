//
//  ViewController.swift
//  JPhotoLibrary
//
//  Created by Macx on 16/12/27.
//  Copyright © 2016年 AidenLance. All rights reserved.
//

import UIKit
import Photos

class TableViewController: UITableViewController {
    let reusedID = "reusedID"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reusedID, for: indexPath)
        cell.textLabel?.text = "原图数据"
        return cell
    }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailTableViewController = DetailTableViewController.init()
        self.navigationController?.pushViewController(detailTableViewController, animated: true)
    }
}


class DetailTabelViewCell : UITableViewCell {
    var selectImage: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectImage = UIImageView.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.bounds.width, height: self.bounds.width)))
        selectImage.clipsToBounds = true
        selectImage.contentMode = .scaleAspectFill
        self.contentView.addSubview(selectImage)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

class DetailTableViewController : UITableViewController {
    let reusedID = "cellID"
    var imageData: [(Data?) -> Void] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(DetailTabelViewCell.self, forCellReuseIdentifier: reusedID)
        self.showPJPhotoAlbum()
        PJPhotoAlbum.shareCenter.callback =  {[unowned self] in self.tableView.reloadData()}
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(withIdentifier: reusedID, for: indexPath) as? DetailTabelViewCell
        else { fatalError("unexpect cell") }
        
        PJPhotoAlbum.shareCenter.getImage(for: indexPath.row) { image in
            guard let image = image else { return }
            cell.imageView?.image = UIImage.init(data: UIImageJPEGRepresentation(image, 0.5)!)
        }

        return cell
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PJPhotoAlbum.shareCenter.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.width
    }
    
    
}


