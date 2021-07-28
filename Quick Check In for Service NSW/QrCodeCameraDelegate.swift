import Foundation
import AVFoundation


class QrCodeCameraDelegate: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    var scanInterval: Double = 1.0
    var lastTime = Date(timeIntervalSince1970: 0)
    
    var onResult: (String) -> Void = { _  in }
    var mockData: String?
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            foundBarcode(stringValue)
        }
    }
    
    @objc func onSimulateScanning(){
        // Fake business data in the form Service NSW QR codes store it
        foundBarcode(mockData ?? "https://www.service.nsw.gov.au/campaign/service-nsw-mobile-app?data=eyJ0IjoiY292aWQxOV9idXNpbmVzcyIsImJpZCI6IjAwMDAwMDAwMDAwMCIsImJuYW1lIjoiRmFrZSBCdXNpbmVzcyIsImJhZGRyZXNzIjoiOTk5OSBNY0V2b3kgU3RyZWV0LCBBbGV4YW5kcmlhIE5TVywgQVVTVFJBTElBIn0")
    }
    
    func foundBarcode(_ stringValue: String) {
        let now = Date()
        if now.timeIntervalSince(lastTime) >= scanInterval {
            lastTime = now
            self.onResult(stringValue)
        }
    }
}
