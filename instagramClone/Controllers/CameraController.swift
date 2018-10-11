//
//  CameraController.swift
//  instagramClone
//
//  Created by Sherif  Wagih on 10/8/18.
//  Copyright © 2018 Sherif  Wagih. All rights reserved.
//

import UIKit
import AVKit
class CameraController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
    }
    fileprivate func setupCaptureSession()
    {
        let captureSession = AVCaptureSession()
        //setup input
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else {return}
        do
        {
            let input = try AVCaptureDeviceInput(device: device)
            if captureSession.canAddInput(input)
            {
                captureSession.addInput(input)
            }
        }
        catch let err
        {
            print("can't setup camera input:",err)
        }
        //setup output
        
        //setup output preview
    }
    override var prefersStatusBarHidden: Bool{
        return true
    }
}
