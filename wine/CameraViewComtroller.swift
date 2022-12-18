//
//  CameraViewComtroller.swift
//  Grapevine
//
//  Created by 2017261069 윤재민 on 2022/12/07.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    let isWinePredictor = IsWinePredictor()
    let predictionsToShow = 2
    
    @IBOutlet var cameraButton:UIButton!
    
    var backFacingCamera: AVCaptureDevice?
    var frontFacingCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice!
    
    var stillImageOutput: AVCapturePhotoOutput!
    var stillImage: UIImage! = nil
    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    let captureSession = AVCaptureSession()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Action methods
    
    @IBAction func capture(sender: UIButton) {
        // Set photo settings
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        
        stillImageOutput.isHighResolutionCaptureEnabled = true
        stillImageOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    // MARK: - Helper methods
    
    private func configure() {
        // Preset the session for taking photo in full resolution
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        // Get the front and back-facing camera for taking photos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .unspecified)
        
        for device in deviceDiscoverySession.devices {
            if device.position == .back {
                backFacingCamera = device
            } else if device.position == .front {
                frontFacingCamera = device
            }
        }
        
        currentDevice = backFacingCamera
        
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: currentDevice) else {
            return
        }
        
        // Configure the session with the output for capturing still images
        stillImageOutput = AVCapturePhotoOutput()
        
        // Configure the session with the input and the output devices
        captureSession.addInput(captureDeviceInput)
        captureSession.addOutput(stillImageOutput)
        
        // Provide a camera preview
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(cameraPreviewLayer!)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.frame = view.layer.frame
        
        // Bring the camera button to front
        view.bringSubviewToFront(cameraButton)
        captureSession.startRunning()
        
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            return
        }
        
        // Get the image from the photo buffer
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        
        stillImage = UIImage(data: imageData)
        classifyIsWine(stillImage)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoViewSegue" {
            guard let infoViewController = segue.destination as? InfoViewController else {return}
            infoViewController.image = self.stillImage
        }
    }
}


// MARK: isWine Classifier
extension CameraViewController {
    private func classifyIsWine(_ image: UIImage) {
        do {
            try self.isWinePredictor.makePredictions(for: image, completionHandler: imagePredictionHandler)
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
    }
    
    private func imagePredictionHandler(_ predictions: [IsWinePredictor.Prediction]?) {
        // When there's no prediction
        guard let predictions = predictions else {
            let alertController = UIAlertController(title: "인식결과 없음", message: "너무 어둡거나 밝지 않은지 확인해보세요", preferredStyle: .alert)
            self.present(alertController, animated: true)
            return
        }
        
        let formattedPredictions = formatPredictions(predictions)
        print(formattedPredictions)
    }
    
    private func formatPredictions(_ predictions: [IsWinePredictor.Prediction]) -> [String] {
        let topPredictions: [String] = predictions.prefix(predictionsToShow).map { prediction in
            let name = prediction.classification
            
            
            if (name == "not wine") {
                performSegue(withIdentifier: "notFoundViewSegue", sender: self)
            } else {
                performSegue(withIdentifier: "infoViewSegue", sender: self)
            }
            
            
            return "\(name) - \(prediction.confidencePercentage)%"
            
        }
        
        return topPredictions
    }
    
}
