//
//  AboutUsViewModel.swift
//  Buzz
//
//  Created by Jay Borania on 29/10/25.
//

class WebPageViewModel: ObservableObject {
    

    // This function is for our refrence as it was used once for base64String to load asset image in html webview
    
    static func generateBase64ForLogo(named imageName: String = "buzz_logo") {
        // Try to load the image from your Assets
        guard let image = UIImage(named: imageName) else {
            print("❌ Image not found in Assets Catalog.")
            return
        }
        
        // Convert image to PNG data (use .jpegData if needed)
        guard let imageData = image.pngData() else {
            print("❌ Failed to convert image to PNG data.")
            return
        }
        
        // Convert image data to Base64 string
        let base64String = imageData.base64EncodedString()
        
        // Create full data URL
        let dataURL = "data:image/png;base64,\(base64String)"
        
        // Print to console
        print("✅ Base64 Logo Generated:\n")
        print(dataURL)
        
        // Optionally save it as a text file in the app's document directory
        if let docsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = docsDir.appendingPathComponent("buzz_logo_base64.txt")
            do {
                try dataURL.write(to: fileURL, atomically: true, encoding: .utf8)
                print("\n📄 Saved Base64 string at: \(fileURL.path)")
            } catch {
                print("❌ Failed to save Base64 string: \(error)")
            }
        }
    }
}
