//
//  IMEViewModel.swift
//  IME-CHAN
//
//  Created by Rei Nakaoka on 2021/11/20.
//

import Foundation
import Combine
import Firebase

class IMEViewModel: ObservableObject {
    let videoCapture = VideoCapture()
    let vision: Vision
    let textRecognizer: VisionTextRecognizer
    @Published var buffImage: UIImage? = nil

    init() {
        FirebaseApp.configure()
        vision = Vision.vision()
        let options = VisionCloudTextRecognizerOptions()
        options.languageHints = ["ja"]
        textRecognizer = vision.cloudTextRecognizer(options: options)
    }

    func startRecognize() {
        let queue = DispatchQueue(label: "naist.yapparifujisan.IME-CHAN")
        for i in 0..<99 {
            queue.async { [self] in
                sleep(3)
                let log = "\(queue.label): \(i)"
                print(log)
                recognizeText(uiImage: self.buffImage!)
            }
        }
    }

    func recognizeText(uiImage: UIImage) {
        let image = VisionImage(image: uiImage)
        textRecognizer.process(image) { result, error in
            guard error == nil, let result = result else { return }
            let resultText = result.text
            print(resultText)
        }
    }

    func runVideo() {
        videoCapture.run { sampleBuffer in
            if let convertImage = self.UIImageFromSampleBuffer(sampleBuffer) {
                DispatchQueue.main.async {
                    self.buffImage = convertImage
                }
            }
        }
        startRecognize()
    }

    func stopVideo() {
        videoCapture.stop()
    }
}

extension IMEViewModel {
    func UIImageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            let context = CIContext()
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image)
            }
        }
        return nil
    }
}
