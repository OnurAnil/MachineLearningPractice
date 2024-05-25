//
//  ViewController.swift
//  MachineLearningImageRecognition
//
//  Created by Onur Anıl on 21.05.2024.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultLable: UILabel!
    
    var choosenImage = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    //FOTO GALERİYE ULAŞMA
    @IBAction func changeClicked(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        //UIImage ı CIImage a çevirdik seçtiğimiz fotoyu tanıyabilmesi için
        if let ciImage = CIImage(image: imageView.image!) {
            choosenImage = ciImage
        }
        
        recognizeImage(image: choosenImage)
    }
    
    
    func recognizeImage(image: CIImage) {
        
        //1) Request
        //2) Handler
        
        resultLable.text = "Finging..."
        
        //1) Request
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            let request = VNCoreMLRequest(model: model) { vnrequest, error in
                
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    if results.count > 0 {
                        
                        let topResults = results.first
                        
                        DispatchQueue.main.async {
                            //
                            let confidenceLevel = (topResults?.confidence ?? 0) * 100
                            
                            let rounded = Int(confidenceLevel * 100) / 100
                            
                            self.resultLable.text = "\(rounded)% it's \(topResults!.identifier)"
                        }
                    }
                }
            }
            //2) Handler
            let handler = VNImageRequestHandler(ciImage: image)
                    DispatchQueue.global(qos: .userInteractive).async {
                        do {
                            try handler.perform([request])
                        } catch {
                            print("error")
                        }
            }
            
        }
        
    }
    
}

