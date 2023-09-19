//
//  QRCodeView.swift
//  WankoNetwork
//
//  Created by satoshoco on 2023/09/16.
//

import SwiftUI
import CoreImage.CIFilterBuiltins
import CoreData

struct QRCodeView: View {
    var profile: Profile
    
    var body: some View {
        let photoBase64 = profile.photo?.base64EncodedString() ?? ""
        let profileData = "\(profile.name ?? ""),\(profile.home ?? ""),\(profile.type ?? ""),\(profile.age),\(profile.gender ?? ""),\(profile.memo ?? ""),\(photoBase64)"
        
        let filter = CIFilter.qrCodeGenerator()
        let context = CIContext()
        let qrData = profileData.data(using: .utf8)
        
        filter.setValue(qrData, forKey: "inputMessage")
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                let uiImage = UIImage(cgImage: cgImage)
                return Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .eraseToAnyView()
            }
        }
        
        return Text("QRコードを生成できませんでした。").eraseToAnyView()
    }
}


extension View {
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }
}

extension UIImage {
    func toBase64() -> String? {
        guard let imageData = self.pngData() else { return nil }
        return imageData.base64EncodedString()
    }
}

extension String {
    func base64ToUIImage() -> UIImage? {
        if let imageData = Data(base64Encoded: self) {
            return UIImage(data: imageData)
        }
        return nil
    }
}

