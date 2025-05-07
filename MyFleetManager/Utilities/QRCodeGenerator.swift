import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeGenerator {
    static func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        // Use only the VIN number without any formatting
        let formattedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Set the input data
        let data = Data(formattedString.utf8)
        filter.setValue(data, forKey: "inputMessage")
        
        // Set the correction level to high for better scanning
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        // Get the output image
        guard let outputImage = filter.outputImage else { return nil }
        
        // Scale the image
        let scale = 10.0
        let transformedImage = outputImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        
        // Convert to UIImage
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}

struct QRCodeView: View {
    let vin: String
    @State private var qrCode: UIImage?
    
    var body: some View {
        VStack {
            if let qrCode = qrCode {
                Image(uiImage: qrCode)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            } else {
                ProgressView()
                    .frame(width: 200, height: 200)
            }
            
            Text("VIN: \(vin)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Scan with fleet management software")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .onAppear {
            qrCode = QRCodeGenerator.generateQRCode(from: vin)
        }
    }
} 