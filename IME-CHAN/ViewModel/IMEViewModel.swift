//
//  IMEViewModel.swift
//  IME-CHAN
//
//  Created by Rei Nakaoka on 2021/11/20.
//

import Foundation
import Combine
import Vision
import Alamofire

class IMEViewModel: ObservableObject {
    let videoCapture = VideoCapture()
    @Published var buffImage: UIImage? = nil
    @Published var recognizedText: String = ""
    @Published var expectWord: [String] = ["","","",""]

    var buffImg: CMSampleBuffer?

    init() {
        runVideo()
    }

    func recognizeText(sampleBuffer: CMSampleBuffer) {
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let maximumCandidates = 1
            self.recognizedText = ""
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                self.recognizedText += candidate.string
            }
            print(self.recognizedText)
            self.request()
        }
        request.recognitionLanguages = ["ja-JP"]

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer)
        try? handler.perform([request])
    }

    func startRecognize() {
        let queue = DispatchQueue(label: "naist.yapparifujisan.IME-CHAN")
        for i in 0..<2000 {
            queue.async { [self] in
                sleep(3)
                let log = "\(queue.label): \(i)"
                print(log)
                recognizeText(sampleBuffer: self.buffImg!)
            }
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
        let url = "http://172.20.10.5:5000"
//        let headers: HTTPHeaders = ["Contenttype": "application/json"]
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
        buffImg = sampleBuffer
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
