//
//  ImageUpload.swift
//  Buzz
//
//  Created by Jay Borania on 08/09/25.
//

import Foundation
import Alamofire
import UIKit

class ImageUploaderService {
    public static let shared = ImageUploaderService()
    private let apiKey = "60ad075788a7204d8a4ca95ecb1df840"
    private let endpoint = "https://api.imgbb.com/1/upload"
    
    func upload(_ image: UIImage, expiration: Int = 0, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8)?.base64EncodedString() else {
            completion(.failure(NSError(domain: "Image encoding failed", code: -1)))
            return
        }
        
        let parameters: Parameters = [
            "key": apiKey,
            "image": imageData,
            "expiration": "\(expiration)"
        ]
        
        AF.request(endpoint, method: .post, parameters: parameters)
            .validate()
            .responseDecodable(of: ImgbbUploadResponse.self) { response in
                switch response.result {
                case .success(let data):
                    let imageURL = data.data.url
                    completion(.success(imageURL))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
