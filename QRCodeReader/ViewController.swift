//
//  ViewController.swift
//  QRCodeReader
//
//  Created by Ali on 3/1/17.
//  Copyright © 2017 Ali. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate{
    
    @IBOutlet weak var infoLabel: UILabel!;
    
    var captureSession : AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var qrCodeFrameView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()
        
        let videoCaptureDecice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let videoInput : AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDecice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(captureMetadataOutput) {
            captureSession.addOutput(captureMetadataOutput)
            
            // got data
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes =
                [AVMetadataObjectTypeQRCode,
                 AVMetadataObjectTypeEAN8Code,
                 AVMetadataObjectTypeEAN13Code,
                 AVMetadataObjectTypeITF14Code,
                 AVMetadataObjectTypePDF417Code,
                 AVMetadataObjectTypeDataMatrixCode,
                 AVMetadataObjectTypeUPCECode
            ]
            
            // initialize the qr-code frame
            setQrCodeFrameView(5, 5, .green)
            
        } else {
            failed();
            return
        }
        
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
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func found(info: String) {
        
        if (infoLabel.isHidden) {
            infoLabel.isHidden = false;
        }
        
        // print text from QR-Code
        infoLabel.text = info;
        
        //add borders to the screen
        view.addSubview(qrCodeFrameView)
        
        // view is covered by main video recorder -> make it visible
        view.bringSubview(toFront: qrCodeFrameView)
    }
    
    func setQrCodeFrameView(_ border: CGFloat,_ radius: CGFloat,_ color: UIColor) {
        qrCodeFrameView = UIView()
        qrCodeFrameView.layer.borderColor = color.cgColor
        qrCodeFrameView.layer.borderWidth = border
        qrCodeFrameView.layer.cornerRadius = radius
        qrCodeFrameView.backgroundColor = UIColor(red: 0, green: 50, blue: 0, alpha: 0.2)
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create URL instance
            if let url = URL(string: urlString) {
                // check if your application can open the URL instance
                return UIApplication.shared.canOpenURL(url )
            }
        }
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func openWebPage(_ sender: UITapGestureRecognizer) {
        if let url = infoLabel.text, verifyUrl(urlString: url) {
            UIApplication.shared.open(URL(string: url)!, options: [:], completionHandler: nil)
        }
    }
}
