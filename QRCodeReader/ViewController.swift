//
//  ViewController.swift
//  QRCodeReader
//
//  Created by Ali on 3/1/17.
//  Copyright © 2017 Ali. All rights reserved.
//

import UIKit
import AVFoundation

extension URL {
    func verify () -> Bool {
        return UIApplication.shared.canOpenURL(self)
    }
}

struct Data {
    static let types = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN8Code,
                 AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeITF14Code,
                 AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeDataMatrixCode,
                 AVMetadataObjectTypeUPCECode]
}

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate{
    
    // MARK: Properties
    
    @IBOutlet weak var infoLabel: UILabel!;
    
    var captureSession : AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var qrCodeFrameView: UIView!
    
    // MARK: ViewController Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        let captureMetadataOutput = AVCaptureMetadataOutput()
        let videoCaptureDecice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        //let videoInput : AVCaptureDeviceInput
        guard let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDecice) else {
            return
        }
        
        guard captureSession.canAddInput(videoInput) else { return }
        captureSession.addInput(videoInput)
        
        guard captureSession.canAddOutput(captureMetadataOutput) else { return }
        captureSession.addOutput(captureMetadataOutput)
        
        // got data
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = Data.types
        
        // initialize the qr-code frame
        setQrCodeFrameView(5, 5, .green)
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        // Specifies that the player should preserve the video’s aspect ratio and fill the layer’s bounds.
        videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        // Setting the video preview size
        videoPreviewLayer.frame = view.layer.bounds
        
        // Adding video preview on the screen
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start findinf the data from video
        captureSession.startRunning() // запуск видео
        
        // Set the Label upper than video view
        view.bringSubview(toFront: infoLabel) // выносим на фронт вью
    }
    
    // MARK: AVCaptureMetadataOutputObjectsDelegate Methods

    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject
            
            let barCode = videoPreviewLayer.transformedMetadataObject(for: readableObject)
            qrCodeFrameView.frame = barCode!.bounds
            
            found(info: readableObject.stringValue)
            
        } else {
            qrCodeFrameView.frame = CGRect.zero
            infoLabel.text = "QR-Code is not detected"
            infoLabel.isHidden = true;
        }
    }
    
    // MARK: Methods
    
    func setQrCodeFrameView(_ border: CGFloat,_ radius: CGFloat,_ color: UIColor) {
        qrCodeFrameView = UIView()
        qrCodeFrameView.layer.borderColor = color.cgColor
        qrCodeFrameView.layer.borderWidth = border
        qrCodeFrameView.layer.cornerRadius = radius
        qrCodeFrameView.backgroundColor = UIColor(red: 0, green: 50, blue: 0, alpha: 0.2)
    }
    
    func found(info: String) {
        
        // show Label
        infoLabel.isHidden = false;
        
        // print text from QR-Code
        infoLabel.text = info;
        
        //add borders to the screen
        view.addSubview(qrCodeFrameView)
        
        // view is covered by main video recorder -> make it visible
        view.bringSubview(toFront: qrCodeFrameView)
    }
    
    // MARK : Settings 
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: Actions
    
    @IBAction func openWebPage(_ sender: UITapGestureRecognizer) {
        if let url = infoLabel.text, let _ = URL(string: url)?.verify() {
            UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
        }
    }
}
