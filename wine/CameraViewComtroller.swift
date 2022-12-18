//
//  CameraViewComtroller.swift
//  Grapevine
//
//  Created by 2017261069 윤재민 on 2022/12/07.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    private let cameraButton: UIButton = {
        let button = UIButton()
        button.setTitle("Camera", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.blue, for: .highlighted)
        button.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var isCameraAuthorized: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    
    let isWinePredictor = IsWinePredictor()
    let predictionsToShow = 2
    var image: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.imageView)
        self.view.addSubview(self.cameraButton)
        
        NSLayoutConstraint.activate([
            self.imageView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.imageView.heightAnchor.constraint(equalToConstant: 300),
            self.imageView.widthAnchor.constraint(equalToConstant: 300),
        ])
        NSLayoutConstraint.activate([
            self.cameraButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.cameraButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        ])
    }
    
    
    @objc private func openCamera() {
#if targetEnvironment(simulator)
        fatalError()
#endif
        
        // Privacy - Camera Usage Description
        AVCaptureDevice.requestAccess(for: .video) { [weak self] isAuthorized in
            guard isAuthorized else {
                self?.showAlertGoToSetting()
                return
            }
            
            DispatchQueue.main.async {
                let pickerController = UIImagePickerController() // must be used from main thread only
                pickerController.sourceType = .camera
                pickerController.allowsEditing = false
                pickerController.mediaTypes = ["public.image"]
                // 만약 비디오가 필요한 경우,
                //      imagePicker.mediaTypes = ["public.movie"]
                //      imagePicker.videoQuality = .typeHigh
                pickerController.delegate = self
                self?.present(pickerController, animated: true)
            }
        }
    }
    
    func showAlertGoToSetting() {
        let alertController = UIAlertController(
            title: "현재 카메라 사용에 대한 접근 권한이 없습니다.",
            message: "설정 > {앱 이름}탭에서 접근을 활성화 할 수 있습니다.",
            preferredStyle: .alert
        )
        let cancelAlert = UIAlertAction(
            title: "취소",
            style: .cancel
        ) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        let goToSettingAlert = UIAlertAction(
            title: "설정으로 이동하기",
            style: .default) { _ in
                guard
                    let settingURL = URL(string: UIApplication.openSettingsURLString),
                    UIApplication.shared.canOpenURL(settingURL)
                else { return }
                UIApplication.shared.open(settingURL, options: [:])
            }
        [cancelAlert, goToSettingAlert]
            .forEach(alertController.addAction(_:))
        DispatchQueue.main.async {
            self.present(alertController, animated: true) // must be used from main thread only
        }
    }
    
}

// isWine Classifier
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
            var name = prediction.classification
            
            
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

extension CameraViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            picker.dismiss(animated: true)
            return
        }
        self.image = image
        self.imageView.image = image
        picker.dismiss(animated: true, completion: nil)
        
        classifyIsWine(image)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "infoViewSegue" {
            guard let infoViewController = segue.destination as? InfoViewController else { return }
            infoViewController.image = self.image
        }
    }
}


