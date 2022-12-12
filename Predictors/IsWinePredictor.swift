//
//  isWinePredictor.swift
//  Grapevine
//
//  Created by 김민우 on 2022/12/12.
//



import Vision
import UIKit


class IsWinePredictor {
    static func createClassifier() -> VNCoreMLModel {
        // Use a default model configuration.
        let defaultConfig = MLModelConfiguration()
        
        // Create an instance of the image classifier's wrapper class.
        let isWineClassifierWrapper = try? isWineClassifier(configuration: defaultConfig)
        
        guard let isWineClassifier = isWineClassifierWrapper else {
            fatalError("App failed to create an image classifier model instance.")
        }
        
        // Get the underlying model instance.
        let isWineClassifierModel = isWineClassifier.model
        
        // Create a Vision instance using the image classifier's model instance.
        guard let isWineClassifierVisionModel = try? VNCoreMLModel(for: isWineClassifierModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }
        
        return isWineClassifierVisionModel
    }
    
    private static let imageClassifier = createClassifier()
    
    struct Prediction {
        let classification: String
        let confidencePercentage: String
    }
    
    typealias ImagePredictionHandler = (_ predictions: [Prediction]?) -> Void
    
    private var predictionHandlers = [VNRequest: ImagePredictionHandler]()
    
    private func createImageClassificationRequest() -> VNImageBasedRequest {
        let imageClassificationRequest = VNCoreMLRequest(model: IsWinePredictor.imageClassifier,
                                                         completionHandler: visionRequestHandler)
        
        imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        return imageClassificationRequest
    }
    
    func makePredictions(for photo: UIImage, completionHandler: @escaping ImagePredictionHandler) throws {
        let orientation = CGImagePropertyOrientation(photo.imageOrientation)
        
        guard let photoImage = photo.cgImage else {
            fatalError("Photo doesn't have underlying CGImage.")
        }
        
        let imageClassificationRequest = createImageClassificationRequest()
        predictionHandlers[imageClassificationRequest] = completionHandler
        
        let handler = VNImageRequestHandler(cgImage: photoImage, orientation: orientation)
        let requests: [VNRequest] = [imageClassificationRequest]
        
        try handler.perform(requests)
    }
    
    private func visionRequestHandler(_ request: VNRequest, error: Error?) {
        guard let predictionHandler = predictionHandlers.removeValue(forKey: request) else {
            fatalError("모든 요청에 대해 핸들러가 존재하지 않습니다");
        }
        
        var predictions: [Prediction]? = nil
        defer {
            predictionHandler(predictions)
        }
        
        if let error = error {
            print("Vision imageClassification error\n\(error.localizedDescription)")
            return
        }
        
        if request.results == nil {
            print("요청 결과가 없습니다")
            return
        }
        
        guard let observations = request.results as? [VNClassificationObservation] else {
            print("VNReqest produced the wrong result type : \(type(of: request.results))")
            return
        }
        
        predictions = observations.map { observation in
            Prediction(classification: observation.identifier, confidencePercentage: observation.confidencePercentageString)
        }
    }
}
