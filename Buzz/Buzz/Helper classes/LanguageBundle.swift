//
//  LanguageBundle.swift
//  MultilanguageDemo
//
//  Created by Jay Borania on 08/12/25.
//
import Foundation

private var associatedBundleKey: UInt8 = 0

final class OverrideBundle: Bundle {
    override func localizedString(forKey key: String,
                                  value: String?,
                                  table tableName: String?) -> String {

        if let bundle = objc_getAssociatedObject(self, &associatedBundleKey) as? Bundle {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        }

        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {

    /// Runtime language override for String Catalogs (.xcstrings)
    static func overrideLanguage(_ language: String) {
        object_setClass(Bundle.main, OverrideBundle.self)

        let path = Bundle.main.path(forResource: language, ofType: "lproj")
        let overrideBundle = path != nil ? Bundle(path: path!) : nil

        objc_setAssociatedObject(Bundle.main,
                                 &associatedBundleKey,
                                 overrideBundle,
                                 .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
