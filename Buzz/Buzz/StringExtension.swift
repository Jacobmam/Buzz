//
//  StringExtension.swift
//  Buzz
//
//  Created by Jay Borania on 03/12/25.
//

import SwiftUI

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    /// Optionally: allow specifying a table
    func localized(tableName: String? = nil) -> String {
        NSLocalizedString(self, tableName: tableName, comment: "")
    }
}
