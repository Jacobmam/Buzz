//
//  LoadingView.swift
//  WWT
//
//  Created by Jay Borania on 10/05/23.
//

import SwiftUI

struct JBLoadingView: View {
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                ProgressView()
                    .tint(.orange)
                
                Text("Please wait...")
            }
        }
    }
}

struct JBLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        JBLoadingView()
    }
}
