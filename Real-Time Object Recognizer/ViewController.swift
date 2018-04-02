//
//  ViewController.swift
//  Real-Time Object Recognizer
//
//  Created by Gbenga Ayobami on 2018-04-02.
//  Copyright © 2018 Gbenga Ayobami. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    let label = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.backgroundColor = .yellow
        label.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
        label.text = "HEYYYYA!!"
        
        // where we start up the camera
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        guard let captureDevice = AVCaptureDevice.default(for: .video) else{ return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else{ return }
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        
        let dataOutput = AVCaptureVideoDataOutput()
        captureSession.addOutput(dataOutput)
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQue"))
        
        
        view.addSubview(label)
//        VNImageRequestHandler(cgImage: <#T##CGImage#>, options: [:]).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
    }

    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        print("camra captured at:", Date())

        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else{return}
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            if err != nil{
                print(err!.localizedDescription)
                return
            }
//            print(finishedReq.results)
            guard let results = finishedReq.results as? [VNClassificationObservation] else{return}
            guard let firstObs = results.first else{return}
            print(firstObs.identifier, firstObs.confidence)
        }
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

