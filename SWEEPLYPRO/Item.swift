//
//  Item.swift
//  SWEEPLYPRO
//
//  Created by Joao Leite on 7/2/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
