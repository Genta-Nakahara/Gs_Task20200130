//
//  ViewController.swift
//  imageAI
//
//  Created by hdymacuser on 2020/01/28.
//  Copyright © 2020 GentaNakahara. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var photoDisplay: UIImageView!
    
    @IBOutlet weak var photoInfoDisplay: UITextView!
    
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        
        
        // Do any additional setup after loading the view.
    }

    @IBAction func takePhoto(_ sender: Any) {
        present(imagePicker,animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        photoDisplay.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imagePicker.dismiss(animated: true, completion: nil)
        imageInference(image: (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)!)
    }
    
    func imageInference(image: UIImage){
        guard  let model = try? VNCoreMLModel(for: Resnet50().model) else {
            fatalError("モデルをロードできません")
        }
        
        let request = VNCoreMLRequest(model: model){
            [weak self]request, error in
            
            guard let results = request.results as? [VNClassificationObservation],
                let firstResult = results.first else{
                    fatalError("判定をできません")
            }
            
            DispatchQueue.main.async {
                self?.photoInfoDisplay.text = "確率 = \(Int(firstResult.confidence * 100))% \n\n詳細 \((firstResult.identifier))"
                 
            }
            
        }
        
        guard  let ciImage = CIImage(image: image) else {
            fatalError("画像を変換できません")
        }
        let imageHandler = VNImageRequestHandler(ciImage: ciImage)
        
        DispatchQueue.global(qos: .userInteractive).async {
            do{
                try imageHandler.perform([request])
            } catch{
                print("エラー　\(error)")
            }
        }
    }
    
}

