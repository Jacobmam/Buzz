//
//  Untitled.swift
//  Buzz
//
//  Created by Jay Borania on 08/09/25.
//


import Foundation

struct ImgbbUploadResponse: Decodable {
    struct DataContent: Decodable {
        let url: String
    }
    let data: DataContent
}
