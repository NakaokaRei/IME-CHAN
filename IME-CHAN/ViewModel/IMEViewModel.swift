//
//  IMEViewModel.swift
//  IME-CHAN
//
//  Created by Rei Nakaoka on 2021/11/20.
//

import Foundation
import Combine
import Firebase
import Alamofire

class IMEViewModel: ObservableObject {
    let videoCapture = VideoCapture()
    let vision: Vision
    let textRecognizer: VisionTextRecognizer
    @Published var buffImage: UIImage? = nil
    @Published var recognizedText: String = ""
    @Published var expectWord: [String] = ["","","",""]

    init() {
        FirebaseApp.configure()
        vision = Vision.vision()
        let options = VisionCloudTextRecognizerOptions()
        options.languageHints = ["ja"]
        textRecognizer = vision.cloudTextRecognizer(options: options)
        runVideo()
    }

    func startRecognize() {
        let queue = DispatchQueue(label: "naist.yapparifujisan.IME-CHAN")
        for i in 0..<2000 {
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
            self.recognizedText = self.cleanRecognizedText(recognizedText: resultText)
            self.request()
        }
    }
    
    func cleanRecognizedText(recognizedText: String) -> String{
//        let cleanText: String = recognizedText.trimmingCharacters(in: .whitespacesAndNewlines)
        let removeWhitesSpacesString = recognizedText.removeWhitespacesAndNewlines
        print(removeWhitesSpacesString)
        return removeWhitesSpacesString
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

    func request() {
        let url = "https://1ccc-180-39-77-67.ngrok.io"
        // let headers: HTTPHeaders = ["Contenttype": "application/json"]
        let parameters:[String: String] = [
            "value": recognizedText
        ]
        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
            guard let data = response.data else { return }
            let response: ResponseModel = try! JSONDecoder().decode(ResponseModel.self, from: data)
            self.expectWord = response.result
            print(self.expectWord)
        }
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

extension StringProtocol where Self: RangeReplaceableCollection {
  var removeWhitespacesAndNewlines: Self {
    filter { !$0.isNewline && !$0.isWhitespace }
  }
}
