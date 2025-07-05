//
//  Item.swift
//  SWEEPLYFINAL
//
//  Created by Joao Leite on 6/30/25.
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
