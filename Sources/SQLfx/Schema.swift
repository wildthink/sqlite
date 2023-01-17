//
//  File.swift
//  
//
//  Created by Jason Jobe on 1/16/23.
//

import Foundation

public struct Scheme {
    var table: String
    var columnKeys: [KeyInfo]
    var columnNames: [String] {
        columnKeys.map { $0.key.stringValue }
    }

    @StringBuilder
    func selectSQL() -> String {
        ""
    }

}
