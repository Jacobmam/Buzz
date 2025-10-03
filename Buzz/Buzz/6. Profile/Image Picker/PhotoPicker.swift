//
//  PhotoPicker.swift
//  Buzz
//
//  Created by Jay Borania on 08/09/25.
//
//
//import SwiftUI
//import YPImagePicker
//
//struct PhotoPicker: UIViewControllerRepresentable {
//    @Environment(\.dismiss) var dismiss
//    @Binding var selectedImage: UIImage
//   
//
//    func makeUIViewController(context: Context) -> some UIViewController {
//        
//        
//        var config = YPImagePickerConfiguration()
//        YPImagePickerConfiguration.shared = config
//        config.screens = [.library, .photo]
//        config.startOnScreen = YPPickerScreen.library
//        config.showsPhotoFilters = false
//        config.icons.capturePhotoImage = UIImage(named: "capture_button")!
//        config.shouldSaveNewPicturesToAlbum = false
//        config.showsCrop = .circle
//        
//        let picker = YPImagePicker(configuration: config)
//        
//        picker.delegate = context.coordinator
//        
//        picker.didFinishPicking { items, cancelled in
//            if !cancelled {
//                let images: [UIImage] = items.compactMap { item in
//                    if case .photo(let photo) = item {
//                        selectedImage = photo.image
//                        return photo.image
//                        
//                    } else {
//                        return nil
//                    }
//                }
//                print(images)
//            }
//            dismiss()
//        }
//        return picker
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, UINavigationControllerDelegate {
//        let parent: PhotoPicker
//        init(_ parent: PhotoPicker) {
//            self.parent = parent
//        }
//    }
//}
import SwiftUI
import PhotosUI

//struct ImagePicker: UIViewControllerRepresentable {
//    @Environment(\.presentationMode) private var presentationMode
//    var sourceType: UIImagePickerController.SourceType = .photoLibrary
//    @Binding var selectedImage: UIImage
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
//        let imagePicker = UIImagePickerController()
////        imagePicker.allowsEditing = false
//        imagePicker.sourceType = sourceType
//        imagePicker.delegate = context.coordinator
////        imagePicker.allowsEditing = true
////        imagePicker.cameraCaptureMode = .photo
//        return imagePicker
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//        var parent: ImagePicker
//
//        init(_ parent: ImagePicker) {
//            self.parent = parent
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//                parent.selectedImage = image
//            }
//            parent.presentationMode.wrappedValue.dismiss()
//        }
//    }
//}
struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var selectedImage: UIImage

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        
        // iOS 18 Fix: Disable conflicting gesture recognizers
        DispatchQueue.main.async {
            imagePicker.view.gestureRecognizers?.forEach { gesture in
                if gesture is UITapGestureRecognizer {
                    gesture.cancelsTouchesInView = false
                    gesture.delaysTouchesBegan = false
                    gesture.delaysTouchesEnded = false
                }
            }
        }
        
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Add delay to prevent gesture conflicts
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                    self.parent.selectedImage = image
                }
                self.parent.presentationMode.wrappedValue.dismiss()
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
