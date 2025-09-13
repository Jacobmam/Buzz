//
//  PhotoPicker.swift
//  Buzz
//
//  Created by Jay Borania on 08/09/25.
//

import SwiftUI
import YPImagePicker

struct PhotoPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedImage: UIImage
   

    func makeUIViewController(context: Context) -> some UIViewController {
        
        
        var config = YPImagePickerConfiguration()
        YPImagePickerConfiguration.shared = config
        config.screens = [.library, .photo]
        config.startOnScreen = YPPickerScreen.library
        config.showsPhotoFilters = false
        config.icons.capturePhotoImage = UIImage(named: "capture_button")!
        config.shouldSaveNewPicturesToAlbum = false
        config.showsCrop = .circle
        
        let picker = YPImagePicker(configuration: config)
        
        picker.delegate = context.coordinator
        
        picker.didFinishPicking { items, cancelled in
            if !cancelled {
                let images: [UIImage] = items.compactMap { item in
                    if case .photo(let photo) = item {
                        selectedImage = photo.image
                        return photo.image
                        
                    } else {
                        return nil
                    }
                }
                print(images)
            }
            dismiss()
        }
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate {
        let parent: PhotoPicker
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
    }
}
