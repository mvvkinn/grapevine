//
//  InfoViewController.swift
//  Grapevine
//
//  Created by 2017261069 윤재민 on 2022/12/14.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class InfoViewController: UIViewController {
    // Wine image from CameraViewController
    var image: UIImage! = nil
    
    let winePredictor = WinePredictor()
    let predictionsToShow = 3
    
    // View Outlet
    @IBOutlet var wineIv: UIImageView!
    @IBOutlet var wineNameLabel: UILabel!
    @IBOutlet var wineCountryLabel: UILabel!
    @IBOutlet var wineAlcoholLabel: UILabel!
    @IBOutlet var wineFeatureLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        wineIv.image = self.image
        classifyWine(self.image)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // query firebase and set label
    func getWineFromDB(_ id : String) {
        let firestore = Firestore.firestore()
        
        firestore.collection("Wines").document(id).getDocument(completion: {(querySnapshot, err) in
            if let err = err {
                print("Error getting info: \(id)", err)
            } else {
                guard let document = querySnapshot?.data() else { return }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: document)
                    let wine = try JSONDecoder().decode(Wine.self, from: jsonData)
                    
                    self.setLabelText(wine: wine)
                    
                } catch let err{
                    print(err)
                }
            }
        })
    }
    
    // Label setter from firestore query
    func setLabelText(wine : Wine) {
        wineNameLabel.text = wine.name
        wineCountryLabel.text = wine.country
        wineAlcoholLabel.text = "\(wine.alcohol)%"
        wineFeatureLabel.text = wine.features
    }
}



// Wine Classifier
extension InfoViewController {
    private func classifyWine(_ image: UIImage) {
        do {
            try self.winePredictor.makePredictions(for: self.image , completionHandler: imagePredictionHandler)
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
    }
    
    private func imagePredictionHandler(_ predictions: [WinePredictor.Prediction]?) {
        // When there's no prediction
        guard let predictions = predictions else {
            let alertController = UIAlertController(title: "인식결과 없음", message: "너무 어둡거나 밝지 않은지 확인해보세요", preferredStyle: .alert)
            self.present(alertController, animated: true)
            return
        }
        
        _ = predictions.prefix(predictionsToShow).map { prediction in
            let name = prediction.classification
            print("\(name), \(prediction.confidencePercentage)%")
            
            getWineFromDB(name)
            
            return name
        }
        
    }
}
