//
//  LoadingView.swift
//  WWT
//
//  Created by Jay Borania on 10/05/23.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            ProgressView()
                .tint(.white)
                .scaleEffect(1)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
