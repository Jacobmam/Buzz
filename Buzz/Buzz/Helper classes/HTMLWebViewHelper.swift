//
//  HTMLWebViewHelper.swift
//  Buzz
//
//  Created by Jay Borania on 29/10/25.
//

import SwiftUI
import WebKit

//struct HTMLWebViewHelper: UIViewRepresentable {
//    let htmlContent: String
//    
//    func makeUIView(context: Context) -> WKWebView {
//        let webView = WKWebView()
//        webView.isOpaque = false
//        webView.backgroundColor = .clear
//        webView.scrollView.backgroundColor = .clear
//        webView.scrollView.showsHorizontalScrollIndicator = false
//        webView.scrollView.showsVerticalScrollIndicator = false
//        webView.loadHTMLString(htmlContent, baseURL: nil)
//        return webView
//    }
//
//    func updateUIView(_ uiView: WKWebView, context: Context) {
//        uiView.loadHTMLString(htmlContent, baseURL: nil)
//    }
//}
//struct HTMLWebViewHelper: UIViewRepresentable {
//    let htmlString: String
//    let baseURL: URL?
//
//    func makeUIView(context: Context) -> WKWebView {
//        let webView = WKWebView()
//        webView.scrollView.isScrollEnabled = true
//        webView.isOpaque = false
//        webView.backgroundColor = .black
//        webView.scrollView.backgroundColor = .black
//        webView.scrollView.bounces = false
//        return webView
//    }
//
//    func updateUIView(_ webView: WKWebView, context: Context) {
//        webView.loadHTMLString(htmlString, baseURL: baseURL)
//    }
//}


struct HTMLWebView: UIViewRepresentable {
    let fileName: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        if let filePath = Bundle.main.path(forResource: fileName, ofType: "html") {
            let fileURL = URL(fileURLWithPath: filePath)
            webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL)
        } else {
            print("❌ File not found: \(fileName).html")
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
