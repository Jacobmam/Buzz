//
//  Fonts.swift
//  HandyBros
//
//  Created by Jay Borania on 22/05/24.
//

import SwiftUI

enum MyFontTypes: String {
 
    case ANTICDIDONE = "Antic Didone"
    case BAHAMAS = "Bahamas"
    case DEROOS = "deroos"
    case POPPINS_BLACK = "Poppins-Black"
    case POPPINS_BLACKITALIC = "Poppins-BlackItalic"
    case POPPINS_BOLD = "Poppins-Bold"
    case POPPINS_BOLDITALIC = "Poppins-BoldItalic"
    case POPPINS_EXTRABOLD = "Poppins-ExtraBold"
    case POPPINS_EXTRABOLDITALIC = "Poppins-ExtraBoldItalic"
    case POPPINS_EXTRALIGHT = "Poppins-ExtraLight"
    case POPPINS_EXTRALIGHTITALIC = "Poppins-ExtraLightItalic"
    case POPPINS_ITALIC = "Poppins-Italic"
    case POPPINS_LIGHT = "Poppins-Light"
    case POPPINS_LIGHTITALIC = "Poppins-LightItalic"
    case POPPINS_MEDIUM = "Poppins-Medium"
    case POPPINS_MEDIUMITALIC = "Poppins-MediumItalic"
    case POPPINS_REGULAR = "Poppins-Regular"
    case POPPINS_SEMIBOLD = "Poppins-SemiBold"
    case POPPINS_SEMIBOLDITALIC = "Poppins-SemiBoldItalic"
    case POPPINS_THIN = "Poppins-Thin"
    case POPPINS_THINITALIC = "Poppins-ThinItalic"
    
    // MARK: - GET MY FONT
    public static func getMyFont(size: CGFloat, type: MyFontTypes) -> Font {
        return Font.custom(type.rawValue, size: size)
    }

}

