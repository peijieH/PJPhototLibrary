//
//  ViewController.swift
//  JPhotoLibrary
//
//  Created by Macx on 16/12/27.
//  Copyright © 2016年 AidenLance. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func activationAction(_ sender: Any) {
        _ = allCollectData()
    }
   
}

