//
//  CustomTextView.swift
//  Buzz
//
//  Created by Jay Borania on 27/11/25.
//

import SwiftUI

struct CustomTextView: View {
    var text: String
    var textSize: CGFloat // = 22
    var fontType: MyFontTypes // = .ManropeRegular
    var textColor: Color //= .white
    var textAlignment: TextAlignment = .leading
    var isLocalized: Bool = true
    
    var body: some View {
        if isLocalized {
            Text(LocalizedStringKey(text))
                .multilineTextAlignment(textAlignment)
                .font(MyFontTypes.getMyFont(size: textSize, type: fontType))
                .foregroundColor(textColor)
        } else {
            Text(text)
                .multilineTextAlignment(textAlignment)
                .font(MyFontTypes.getMyFont(size: textSize, type: fontType))
                .foregroundColor(textColor)
        }
    }
}

struct CustomTextView_Previews: PreviewProvider {
    static var previews: some View {
        CustomTextView(text: "Text", textSize: 15, fontType: .BAHAMAS, textColor: .black, textAlignment: .leading)
    }
}
