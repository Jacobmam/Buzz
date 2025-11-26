//
//  AboutUsView.swift
//  Buzz
//
//  Created by Jay Borania on 29/10/25.
//
import SwiftUI
import WebKit

// MARK: - AboutView
struct WebPageView: View {
    @Environment(\.dismiss) var dismiss
    var webviewName: WebviewName
    @State private var headerText: String = ""
    @State private var fileName: String = ""
    var body: some View {
        VStack {
            headerView
            if fileName.count > 0 {
                HTMLWebView(fileName: fileName)
                    .onAppear {
                        print("fileName: \(fileName)")
                    }
            } else {
                JBLoadingView()
            }
        }
        .onAppear {
            switch webviewName {
            case .aboutUsView:
                self.headerText = "About Us"
                self.fileName = webviewName.rawValue
                break
            case .privacyTermsView:
                self.headerText = "Privacy & Tearms"
                self.fileName = webviewName.rawValue
                break
            }
        }
    }
    var headerView: some View {
          HStack {
              Button {
                  dismiss()
              } label: {
                  Image(systemName: "chevron.left")
                      .resizable()
                      .scaledToFit()
                      .tint(.orange)
                      .frame(height: 20)
                      .bold()
              }
              .frame(width: 50, height: 50)
  
              Text(headerText)
                  .fontWeight(.bold)
                  .foregroundColor(.orange)
                  .font(.system(size: 20))
  
              Spacer()
          }
          .background(.black)
          .padding(.leading, 10)
      }
}
